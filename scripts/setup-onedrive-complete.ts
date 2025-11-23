/**
 * Script completo para configurar OneDrive e gerar estrutura SQL
 * 
 * Este script:
 * 1. Analisa toda a estrutura do OneDrive
 * 2. Configura permissões de todas as pastas/arquivos
 * 3. Gera SQL para importar na plataforma
 * 
 * USO:
 * npx ts-node scripts/setup-onedrive-complete.ts
 */

import { Client } from '@microsoft/microsoft-graph-client';
import 'isomorphic-fetch';
import * as fs from 'fs';
import * as path from 'path';

const ONEDRIVE_FOLDER_URL = 'https://acadcruzeirodosul-my.sharepoint.com/:f:/g/personal/rafael_dias993_cs_ceunsp_edu_br/IgAz3pLjixnLRa1HFKQCkrTTAZpNqnlhrva_cwlScOZsmu0?e=3SxAaJ';

interface CourseData {
  courseName: string;
  description: string;
  category: string;
  instructor: string;
  modules: ModuleData[];
}

interface ModuleData {
  moduleName: string;
  description: string;
  lessons: LessonData[];
}

interface LessonData {
  title: string;
  description: string;
  videoUrl: string;
  durationMinutes?: number;
  size: number;
}

/**
 * Processa estrutura completa e gera tudo
 */
async function setupComplete(
  graphClient: Client,
  folderId: string
): Promise<CourseData[]> {
  const courses: CourseData[] = [];

  console.log('📁 Analisando estrutura do OneDrive...\n');

  // Listar cursos (pastas principais)
  const rootItems = await graphClient
    .api(`/sites/root/drive/items/${folderId}/children`)
    .get();

  for (const courseFolder of rootItems.value) {
    if (!courseFolder.folder) continue;

    console.log(`📚 Processando curso: ${courseFolder.name}`);

    const course: CourseData = {
      courseName: courseFolder.name,
      description: `Curso: ${courseFolder.name}`,
      category: 'plataforma',
      instructor: 'Instituto dos Sonhos',
      modules: [],
    };

    // Configurar permissões da pasta do curso
    try {
      await graphClient
        .api(`/sites/root/drive/items/${courseFolder.id}/createLink`)
        .post({ type: 'view', scope: 'anonymous' });
      console.log(`  ✅ Permissões configuradas`);
    } catch (error) {
      console.log(`  ⚠️  Erro ao configurar permissões: ${error}`);
    }

    // Listar módulos
    const moduleItems = await graphClient
      .api(`/sites/root/drive/items/${courseFolder.id}/children`)
      .get();

    for (const moduleFolder of moduleItems.value) {
      if (!moduleFolder.folder) continue;

      console.log(`  📦 Processando módulo: ${moduleFolder.name}`);

      const module: ModuleData = {
        moduleName: moduleFolder.name,
        description: `Módulo: ${moduleFolder.name}`,
        lessons: [],
      };

      // Configurar permissões do módulo
      try {
        await graphClient
          .api(`/sites/root/drive/items/${moduleFolder.id}/createLink`)
          .post({ type: 'view', scope: 'anonymous' });
      } catch (error) {
        // Ignorar erros menores
      }

      // Listar aulas (vídeos)
      const lessonItems = await graphClient
        .api(`/sites/root/drive/items/${moduleFolder.id}/children`)
        .get();

      for (const lessonFile of lessonItems.value) {
        if (!lessonFile.file) continue;

        // Verificar se é vídeo
        const mimeType = lessonFile.file.mimeType || '';
        if (!mimeType.startsWith('video/')) continue;

        console.log(`    🎥 Encontrado vídeo: ${lessonFile.name}`);

        // Configurar permissões do vídeo
        try {
          await graphClient
            .api(`/sites/root/drive/items/${lessonFile.id}/createLink`)
            .post({ type: 'view', scope: 'anonymous' });
        } catch (error) {
          console.log(`      ⚠️  Erro ao configurar permissões do vídeo`);
        }

        const lesson: LessonData = {
          title: lessonFile.name.replace(/\.[^/.]+$/, ''), // Remove extensão
          description: `Aula: ${lessonFile.name}`,
          videoUrl: lessonFile.webUrl,
          durationMinutes: 0, // Pode ser calculado depois
          size: lessonFile.size || 0,
        };

        module.lessons.push(lesson);
      }

      if (module.lessons.length > 0) {
        course.modules.push(module);
      }
    }

    if (course.modules.length > 0) {
      courses.push(course);
    }

    console.log('');
  }

  return courses;
}

/**
 * Gera SQL de importação
 */
function generateSQL(courses: CourseData[]): string {
  let sql = '-- SQL gerado automaticamente\n';
  sql += '-- Estrutura completa do OneDrive\n';
  sql += '-- Execute no Supabase SQL Editor\n\n';
  sql += 'BEGIN;\n\n';

  courses.forEach((course, courseIndex) => {
    sql += `-- ============================================\n`;
    sql += `-- CURSO: ${course.courseName}\n`;
    sql += `-- ============================================\n\n`;

    // Inserir curso
    sql += `INSERT INTO public.courses (\n`;
    sql += `  title, description, category, is_published, instructor_name, created_at\n`;
    sql += `) VALUES (\n`;
    sql += `  '${escapeSQL(course.courseName)}',\n`;
    sql += `  '${escapeSQL(course.description)}',\n`;
    sql += `  '${escapeSQL(course.category)}',\n`;
    sql += `  true,\n`;
    sql += `  '${escapeSQL(course.instructor)}',\n`;
    sql += `  now()\n`;
    sql += `) RETURNING id;\n\n`;

    // Inserir módulos e aulas
    course.modules.forEach((module, moduleIndex) => {
      sql += `-- Módulo: ${module.moduleName}\n`;
      sql += `INSERT INTO public.course_modules (\n`;
      sql += `  title, description, course_id, order_index, created_at\n`;
      sql += `) SELECT \n`;
      sql += `  '${escapeSQL(module.moduleName)}',\n`;
      sql += `  '${escapeSQL(module.description)}',\n`;
      sql += `  c.id,\n`;
      sql += `  ${moduleIndex + 1},\n`;
      sql += `  now()\n`;
      sql += `FROM public.courses c\n`;
      sql += `WHERE c.title = '${escapeSQL(course.courseName)}'\n`;
      sql += `RETURNING id;\n\n`;

      // Inserir aulas
      module.lessons.forEach((lesson, lessonIndex) => {
        sql += `-- Aula: ${lesson.title}\n`;
        sql += `INSERT INTO public.lessons (\n`;
        sql += `  title, description, module_id, video_url, order_index, duration_minutes, created_at\n`;
        sql += `) SELECT \n`;
        sql += `  '${escapeSQL(lesson.title)}',\n`;
        sql += `  '${escapeSQL(lesson.description)}',\n`;
        sql += `  cm.id,\n`;
        sql += `  '${escapeSQL(lesson.videoUrl)}',\n`;
        sql += `  ${lessonIndex + 1},\n`;
        sql += `  ${lesson.durationMinutes || 0},\n`;
        sql += `  now()\n`;
        sql += `FROM public.course_modules cm\n`;
        sql += `WHERE cm.title = '${escapeSQL(module.moduleName)}'\n`;
        sql += `  AND cm.course_id = (SELECT id FROM public.courses WHERE title = '${escapeSQL(course.courseName)}');\n\n`;
      });
    });

    sql += '\n';
  });

  sql += 'COMMIT;\n\n';
  sql += '-- Verificar importação\n';
  sql += 'SELECT \n';
  sql += '  c.title as curso,\n';
  sql += '  COUNT(DISTINCT cm.id) as modulos,\n';
  sql += '  COUNT(DISTINCT l.id) as aulas\n';
  sql += 'FROM public.courses c\n';
  sql += 'LEFT JOIN public.course_modules cm ON cm.course_id = c.id\n';
  sql += 'LEFT JOIN public.lessons l ON l.module_id = cm.id\n';
  sql += 'GROUP BY c.id, c.title\n';
  sql += 'ORDER BY c.created_at DESC;\n';

  return sql;
}

function escapeSQL(str: string): string {
  return str.replace(/'/g, "''");
}

/**
 * Função principal
 */
async function main() {
  console.log('🚀 Iniciando configuração completa do OneDrive...\n');

  const folderId = ONEDRIVE_FOLDER_URL.match(/\/personal\/[^\/]+\/([^?]+)/)?.[1];
  if (!folderId) {
    console.error('❌ Não foi possível extrair o ID da pasta');
    return;
  }

  console.log('⚠️  Este script requer autenticação Microsoft Graph API');
  console.log('📖 Veja GUIA_CONFIGURACAO_PERMISSOES.md para instruções\n');

  // Exemplo de uso:
  /*
  const graphClient = Client.init({
    authProvider: async (done) => {
      const token = await getAccessToken();
      done(null, token);
    },
  });

  const courses = await setupComplete(graphClient, folderId);

  // Gerar SQL
  const sql = generateSQL(courses);
  fs.writeFileSync('import-courses-complete.sql', sql);

  // Gerar JSON
  fs.writeFileSync('courses-structure.json', JSON.stringify(courses, null, 2));

  console.log('\n✅ Configuração completa!');
  console.log('📄 Arquivos gerados:');
  console.log('   - import-courses-complete.sql');
  console.log('   - courses-structure.json');
  */
}

if (require.main === module) {
  main().catch(console.error);
}

export { setupComplete, generateSQL };

