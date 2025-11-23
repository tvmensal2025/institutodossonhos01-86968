/**
 * Script para analisar TODAS as aulas do OneDrive/SharePoint
 * 
 * Este script percorre recursivamente todas as pastas e lista:
 * - Todos os cursos
 * - Todos os módulos
 * - Todas as aulas (vídeos)
 * 
 * Gera relatórios completos e SQL para importação
 */

import { Client } from '@microsoft/microsoft-graph-client';
import 'isomorphic-fetch';
import * as fs from 'fs';
import * as path from 'path';

const ONEDRIVE_FOLDER_URL = 'https://acadcruzeirodosul-my.sharepoint.com/:f:/g/personal/rafael_dias993_cs_ceunsp_edu_br/IgAz3pLjixnLRa1HFKQCkrTTAZpNqnlhrva_cwlScOZsmu0?e=3SxAaJ';

interface LessonInfo {
  title: string;
  url: string;
  size: number;
  duration?: number;
  mimeType: string;
  moduleName: string;
  courseName: string;
  path: string;
}

interface ModuleInfo {
  moduleName: string;
  courseName: string;
  lessons: LessonInfo[];
  path: string;
}

interface CourseInfo {
  courseName: string;
  modules: ModuleInfo[];
  totalLessons: number;
  totalSize: number;
  path: string;
}

/**
 * Extrai ID da pasta do URL
 */
function extractFolderId(url: string): string | null {
  try {
    const match = url.match(/\/personal\/[^\/]+\/([^?]+)/);
    return match ? match[1] : null;
  } catch {
    return null;
  }
}

/**
 * Verifica se é arquivo de vídeo
 */
function isVideoFile(mimeType: string): boolean {
  const videoTypes = [
    'video/mp4',
    'video/webm',
    'video/ogg',
    'video/quicktime',
    'video/x-msvideo',
    'video/x-ms-wmv',
    'video/x-matroska',
  ];
  return videoTypes.some(type => mimeType.toLowerCase().includes(type));
}

/**
 * Analisa recursivamente todas as pastas e arquivos
 */
async function analyzeAllLessons(
  graphClient: Client,
  folderId: string,
  currentPath: string = ''
): Promise<CourseInfo[]> {
  const courses: CourseInfo[] = [];
  
  try {
    console.log(`📁 Analisando: ${currentPath || 'Raiz'}`);
    
    // Listar itens na pasta atual
    const items = await graphClient
      .api(`/sites/root/drive/items/${folderId}/children`)
      .expand('children')
      .get();

    // Processar cada item
    for (const item of items.value) {
      const itemPath = currentPath ? `${currentPath}/${item.name}` : item.name;

      if (item.folder) {
        // É uma pasta - pode ser curso, módulo ou subpasta
        
        // Verificar se tem vídeos diretamente ou apenas subpastas
        const subItems = await graphClient
          .api(`/sites/root/drive/items/${item.id}/children`)
          .get();

        const hasVideos = subItems.value.some(
          (subItem: any) => subItem.file && isVideoFile(subItem.file.mimeType || '')
        );

        if (hasVideos) {
          // Esta pasta contém vídeos diretamente - é um módulo
          console.log(`  📦 Módulo encontrado: ${item.name}`);
          
          // Encontrar o curso pai (pasta anterior)
          const courseName = currentPath.split('/')[0] || item.name;
          const moduleName = item.name;
          
          let course = courses.find(c => c.courseName === courseName);
          if (!course) {
            course = {
              courseName: courseName,
              modules: [],
              totalLessons: 0,
              totalSize: 0,
              path: currentPath.split('/')[0] || '',
            };
            courses.push(course);
          }

          const module: ModuleInfo = {
            moduleName: moduleName,
            courseName: courseName,
            lessons: [],
            path: itemPath,
          };

          // Processar vídeos nesta pasta
          for (const subItem of subItems.value) {
            if (subItem.file && isVideoFile(subItem.file.mimeType || '')) {
              const lesson: LessonInfo = {
                title: subItem.name.replace(/\.[^/.]+$/, ''), // Remove extensão
                url: subItem.webUrl,
                size: subItem.size || 0,
                duration: subItem.video?.duration,
                mimeType: subItem.file.mimeType,
                moduleName: moduleName,
                courseName: courseName,
                path: `${itemPath}/${subItem.name}`,
              };
              
              module.lessons.push(lesson);
              course.totalLessons++;
              course.totalSize += lesson.size;
              
              console.log(`    🎥 Aula: ${subItem.name}`);
            }
          }

          if (module.lessons.length > 0) {
            course.modules.push(module);
          }
        } else {
          // É uma pasta de curso (contém módulos)
          console.log(`📚 Curso encontrado: ${item.name}`);
          
          // Analisar recursivamente
          const subCourses = await analyzeAllLessons(
            graphClient,
            item.id,
            itemPath
          );
          
          courses.push(...subCourses);
        }
      } else if (item.file && isVideoFile(item.file.mimeType || '')) {
        // Vídeo na raiz (improvável, mas possível)
        console.log(`  🎥 Vídeo na raiz: ${item.name}`);
      }
    }
  } catch (error: any) {
    console.error(`❌ Erro ao analisar ${currentPath}:`, error.message);
  }

  return courses;
}

/**
 * Gera relatório completo em texto
 */
function generateFullReport(courses: CourseInfo[]): string {
  let report = '📊 RELATÓRIO COMPLETO - TODAS AS AULAS\n';
  report += '='.repeat(80) + '\n\n';
  
  let totalCourses = courses.length;
  let totalModules = 0;
  let totalLessons = 0;
  let totalSize = 0;

  for (const course of courses) {
    totalModules += course.modules.length;
    totalLessons += course.totalLessons;
    totalSize += course.totalSize;

    report += `📚 CURSO: ${course.courseName}\n`;
    report += `   📍 Caminho: ${course.path}\n`;
    report += `   📦 Módulos: ${course.modules.length}\n`;
    report += `   🎥 Total de Aulas: ${course.totalLessons}\n`;
    report += `   💾 Tamanho Total: ${formatBytes(course.totalSize)}\n\n`;

    for (const module of course.modules) {
      report += `   📁 MÓDULO: ${module.moduleName}\n`;
      report += `      📍 Caminho: ${module.path}\n`;
      report += `      🎥 Aulas: ${module.lessons.length}\n\n`;

      for (const lesson of module.lessons) {
        report += `      🎬 ${lesson.title}\n`;
        report += `         📍 ${lesson.path}\n`;
        report += `         🔗 ${lesson.url}\n`;
        report += `         💾 ${formatBytes(lesson.size)}\n`;
        if (lesson.duration) {
          report += `         ⏱️  ${formatDuration(lesson.duration)}\n`;
        }
        report += `\n`;
      }
    }

    report += '\n' + '-'.repeat(80) + '\n\n';
  }

  report += `📈 ESTATÍSTICAS GERAIS\n`;
  report += `   📚 Total de Cursos: ${totalCourses}\n`;
  report += `   📦 Total de Módulos: ${totalModules}\n`;
  report += `   🎥 Total de Aulas: ${totalLessons}\n`;
  report += `   💾 Tamanho Total: ${formatBytes(totalSize)}\n`;

  return report;
}

/**
 * Gera SQL completo para importação
 */
function generateCompleteSQL(courses: CourseInfo[]): string {
  let sql = '-- ============================================\n';
  sql += '-- SQL COMPLETO - IMPORTAR TODAS AS AULAS\n';
  sql += '-- Gerado automaticamente da análise do OneDrive\n';
  sql += '-- ============================================\n\n';
  sql += 'BEGIN;\n\n';

  for (let i = 0; i < courses.length; i++) {
    const course = courses[i];

    sql += `-- ============================================\n`;
    sql += `-- CURSO ${i + 1}/${courses.length}: ${course.courseName}\n`;
    sql += `-- ============================================\n\n`;

    // Inserir curso
    sql += `INSERT INTO public.courses (\n`;
    sql += `  title,\n`;
    sql += `  description,\n`;
    sql += `  category,\n`;
    sql += `  is_published,\n`;
    sql += `  instructor_name,\n`;
    sql += `  duration_minutes,\n`;
    sql += `  created_at\n`;
    sql += `) VALUES (\n`;
    sql += `  '${escapeSQL(course.courseName)}',\n`;
    sql += `  'Curso completo importado do OneDrive - ${course.totalLessons} aulas',\n`;
    sql += `  'plataforma',\n`;
    sql += `  true,\n`;
    sql += `  'Instituto dos Sonhos',\n`;
    sql += `  ${Math.round(course.totalSize / 1024 / 1024 / 10)}, -- Estimativa\n`;
    sql += `  now()\n`;
    sql += `) ON CONFLICT DO NOTHING RETURNING id;\n\n`;

    // Inserir módulos e aulas
    for (let j = 0; j < course.modules.length; j++) {
      const module = course.modules[j];

      sql += `-- Módulo ${j + 1}/${course.modules.length}: ${module.moduleName}\n`;
      sql += `INSERT INTO public.course_modules (\n`;
      sql += `  title,\n`;
      sql += `  description,\n`;
      sql += `  course_id,\n`;
      sql += `  order_index,\n`;
      sql += `  created_at\n`;
      sql += `) SELECT \n`;
      sql += `  '${escapeSQL(module.moduleName)}',\n`;
      sql += `  'Módulo com ${module.lessons.length} aulas',\n`;
      sql += `  c.id,\n`;
      sql += `  ${j + 1},\n`;
      sql += `  now()\n`;
      sql += `FROM public.courses c\n`;
      sql += `WHERE c.title = '${escapeSQL(course.courseName)}'\n`;
      sql += `ON CONFLICT DO NOTHING RETURNING id;\n\n`;

      // Inserir todas as aulas do módulo
      for (let k = 0; k < module.lessons.length; k++) {
        const lesson = module.lessons[k];

        sql += `-- Aula ${k + 1}/${module.lessons.length}: ${lesson.title}\n`;
        sql += `INSERT INTO public.lessons (\n`;
        sql += `  title,\n`;
        sql += `  description,\n`;
        sql += `  module_id,\n`;
        sql += `  video_url,\n`;
        sql += `  order_index,\n`;
        sql += `  duration_minutes,\n`;
        sql += `  created_at\n`;
        sql += `) SELECT \n`;
        sql += `  '${escapeSQL(lesson.title)}',\n`;
        sql += `  'Aula do curso ${escapeSQL(course.courseName)}',\n`;
        sql += `  cm.id,\n`;
        sql += `  '${escapeSQL(lesson.url)}',\n`;
        sql += `  ${k + 1},\n`;
        sql += `  ${lesson.duration ? Math.round(lesson.duration / 60) : 0},\n`;
        sql += `  now()\n`;
        sql += `FROM public.course_modules cm\n`;
        sql += `WHERE cm.title = '${escapeSQL(module.moduleName)}'\n`;
        sql += `  AND cm.course_id = (SELECT id FROM public.courses WHERE title = '${escapeSQL(course.courseName)}')\n`;
        sql += `ON CONFLICT DO NOTHING;\n\n`;
      }
    }

    sql += '\n';
  }

  sql += 'COMMIT;\n\n';
  
  sql += '-- ============================================\n';
  sql += '-- VERIFICAÇÃO DA IMPORTAÇÃO\n';
  sql += '-- ============================================\n\n';
  sql += 'SELECT \n';
  sql += '  c.title as curso,\n';
  sql += '  COUNT(DISTINCT cm.id) as total_modulos,\n';
  sql += '  COUNT(DISTINCT l.id) as total_aulas,\n';
  sql += '  SUM(l.duration_minutes) as duracao_total_minutos\n';
  sql += 'FROM public.courses c\n';
  sql += 'LEFT JOIN public.course_modules cm ON cm.course_id = c.id\n';
  sql += 'LEFT JOIN public.lessons l ON l.module_id = cm.id\n';
  sql += 'GROUP BY c.id, c.title\n';
  sql += 'ORDER BY c.created_at DESC;\n';

  return sql;
}

/**
 * Gera JSON estruturado completo
 */
function generateCompleteJSON(courses: CourseInfo[]): string {
  const structure = {
    metadata: {
      generatedAt: new Date().toISOString(),
      source: 'OneDrive/SharePoint Analysis',
      totalCourses: courses.length,
      totalModules: courses.reduce((sum, c) => sum + c.modules.length, 0),
      totalLessons: courses.reduce((sum, c) => sum + c.totalLessons, 0),
      totalSize: courses.reduce((sum, c) => sum + c.totalSize, 0),
    },
    courses: courses.map(course => ({
      courseName: course.courseName,
      path: course.path,
      totalLessons: course.totalLessons,
      totalSize: course.totalSize,
      modules: course.modules.map(module => ({
        moduleName: module.moduleName,
        path: module.path,
        lessons: module.lessons.map(lesson => ({
          title: lesson.title,
          url: lesson.url,
          path: lesson.path,
          size: lesson.size,
          duration: lesson.duration,
          mimeType: lesson.mimeType,
        })),
      })),
    })),
  };

  return JSON.stringify(structure, null, 2);
}

function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

function formatDuration(seconds: number): string {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;
  
  if (hours > 0) {
    return `${hours}h ${minutes}m ${secs}s`;
  }
  return `${minutes}m ${secs}s`;
}

function escapeSQL(str: string): string {
  return str.replace(/'/g, "''").replace(/\\/g, '\\\\');
}

/**
 * Função principal
 */
async function main() {
  console.log('🚀 Iniciando análise completa de TODAS as aulas...\n');

  const folderId = extractFolderId(ONEDRIVE_FOLDER_URL);
  if (!folderId) {
    console.error('❌ Não foi possível extrair o ID da pasta');
    return;
  }

  console.log(`📁 ID da pasta: ${folderId}\n`);
  console.log('⚠️  Este script requer autenticação Microsoft Graph API\n');
  console.log('📖 Veja GUIA_IMPORTACAO_ONEDRIVE.md para instruções completas\n');

  // Exemplo de uso (requer configuração):
  /*
  const graphClient = Client.init({
    authProvider: async (done) => {
      const token = await getAccessToken();
      done(null, token);
    },
  });

  console.log('📊 Analisando estrutura completa...\n');
  const courses = await analyzeAllLessons(graphClient, folderId);

  console.log(`\n✅ Análise completa!\n`);
  console.log(`   📚 Cursos encontrados: ${courses.length}`);
  console.log(`   📦 Módulos encontrados: ${courses.reduce((sum, c) => sum + c.modules.length, 0)}`);
  console.log(`   🎥 Aulas encontradas: ${courses.reduce((sum, c) => sum + c.totalLessons, 0)}\n`);

  // Gerar relatórios
  const report = generateFullReport(courses);
  const sql = generateCompleteSQL(courses);
  const json = generateCompleteJSON(courses);

  // Salvar arquivos
  fs.writeFileSync('relatorio-completo-aulas.txt', report, 'utf8');
  fs.writeFileSync('import-todas-aulas.sql', sql, 'utf8');
  fs.writeFileSync('estrutura-completa.json', json, 'utf8');

  console.log('📄 Arquivos gerados:');
  console.log('   - relatorio-completo-aulas.txt');
  console.log('   - import-todas-aulas.sql');
  console.log('   - estrutura-completa.json\n');
  */
}

if (require.main === module) {
  main().catch(console.error);
}

export {
  analyzeAllLessons,
  generateFullReport,
  generateCompleteSQL,
  generateCompleteJSON,
};

