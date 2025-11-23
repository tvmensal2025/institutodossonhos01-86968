/**
 * Script para analisar cursos do OneDrive/SharePoint
 * 
 * Este script ajuda a listar e processar cursos armazenados no OneDrive
 * 
 * USO:
 * 1. Instale as dependências: npm install @microsoft/microsoft-graph-client axios
 * 2. Configure as credenciais do Microsoft Graph API
 * 3. Execute: npx ts-node scripts/analyze-onedrive-courses.ts
 */

import { Client } from '@microsoft/microsoft-graph-client';
import 'isomorphic-fetch';

interface OneDriveItem {
  id: string;
  name: string;
  webUrl: string;
  folder?: {
    childCount: number;
  };
  file?: {
    mimeType: string;
    size: number;
  };
  video?: {
    duration: number;
    width: number;
    height: number;
  };
}

interface CourseStructure {
  courseName: string;
  modules: ModuleStructure[];
  totalVideos: number;
  totalSize: number;
}

interface ModuleStructure {
  moduleName: string;
  lessons: LessonStructure[];
}

interface LessonStructure {
  name: string;
  url: string;
  size: number;
  duration?: number;
  mimeType: string;
}

// URL da pasta do OneDrive fornecida
const ONEDRIVE_FOLDER_URL = 'https://acadcruzeirodosul-my.sharepoint.com/:f:/g/personal/rafael_dias993_cs_ceunsp_edu_br/IgAz3pLjixnLRa1HFKQCkrTTAb5rCPJ7HqxF_mOIb6Dli6g?e=08PdvC';

/**
 * Extrai o ID da pasta do URL do SharePoint
 */
function extractFolderIdFromUrl(url: string): string | null {
  try {
    // Formato: https://[tenant].sharepoint.com/:f:/g/personal/.../[FOLDER_ID]?e=...
    const match = url.match(/\/personal\/[^\/]+\/([^?]+)/);
    if (match && match[1]) {
      return match[1];
    }
    return null;
  } catch {
    return null;
  }
}

/**
 * Analisa a estrutura de pastas do OneDrive
 * 
 * ESTRUTURA ESPERADA:
 * - Pasta Raiz (Cursos)
 *   - Curso 1
 *     - Módulo 1
 *       - Aula 1.mp4
 *       - Aula 2.mp4
 *     - Módulo 2
 *       - Aula 1.mp4
 *   - Curso 2
 *     - ...
 */
async function analyzeOneDriveStructure(
  graphClient: Client,
  folderId: string
): Promise<CourseStructure[]> {
  const courses: CourseStructure[] = [];

  try {
    // Listar itens na pasta raiz (cursos)
    const rootItems = await graphClient
      .api(`/sites/root/drive/items/${folderId}/children`)
      .get();

    for (const item of rootItems.value as OneDriveItem[]) {
      // Se for uma pasta, é um curso
      if (item.folder) {
        const course: CourseStructure = {
          courseName: item.name,
          modules: [],
          totalVideos: 0,
          totalSize: 0,
        };

        // Listar módulos dentro do curso
        const moduleItems = await graphClient
          .api(`/sites/root/drive/items/${item.id}/children`)
          .get();

        for (const moduleItem of moduleItems.value as OneDriveItem[]) {
          if (moduleItem.folder) {
            const module: ModuleStructure = {
              moduleName: moduleItem.name,
              lessons: [],
            };

            // Listar aulas dentro do módulo
            const lessonItems = await graphClient
              .api(`/sites/root/drive/items/${moduleItem.id}/children`)
              .get();

            for (const lessonItem of lessonItems.value as OneDriveItem[]) {
              // Se for um arquivo de vídeo
              if (lessonItem.file && isVideoFile(lessonItem.file.mimeType)) {
                const lesson: LessonStructure = {
                  name: lessonItem.name,
                  url: lessonItem.webUrl,
                  size: lessonItem.file.size || 0,
                  duration: lessonItem.video?.duration,
                  mimeType: lessonItem.file.mimeType,
                };

                module.lessons.push(lesson);
                course.totalVideos++;
                course.totalSize += lesson.size;
              }
            }

            if (module.lessons.length > 0) {
              course.modules.push(module);
            }
          }
        }

        if (course.modules.length > 0) {
          courses.push(course);
        }
      }
    }
  } catch (error) {
    console.error('Erro ao analisar estrutura do OneDrive:', error);
    throw error;
  }

  return courses;
}

/**
 * Verifica se o arquivo é um vídeo
 */
function isVideoFile(mimeType: string): boolean {
  const videoMimeTypes = [
    'video/mp4',
    'video/webm',
    'video/ogg',
    'video/quicktime',
    'video/x-msvideo',
    'video/x-ms-wmv',
  ];
  return videoMimeTypes.includes(mimeType);
}

/**
 * Gera relatório em texto
 */
function generateTextReport(courses: CourseStructure[]): string {
  let report = '📊 RELATÓRIO DE CURSOS DO ONEDRIVE\n';
  report += '='.repeat(60) + '\n\n';

  for (const course of courses) {
    report += `📚 CURSO: ${course.courseName}\n`;
    report += `   📹 Total de vídeos: ${course.totalVideos}\n`;
    report += `   💾 Tamanho total: ${formatBytes(course.totalSize)}\n`;
    report += `   📦 Módulos: ${course.modules.length}\n\n`;

    for (const module of course.modules) {
      report += `   📁 MÓDULO: ${module.moduleName}\n`;
      report += `      Aulas: ${module.lessons.length}\n`;

      for (const lesson of module.lessons) {
        report += `      - ${lesson.name} (${formatBytes(lesson.size)})\n`;
        report += `        URL: ${lesson.url}\n`;
      }
      report += '\n';
    }

    report += '\n';
  }

  return report;
}

/**
 * Gera SQL para importar cursos no banco de dados
 */
function generateSQLImport(courses: CourseStructure[]): string {
  let sql = '-- SQL gerado automaticamente para importar cursos do OneDrive\n';
  sql += '-- Execute este script no Supabase SQL Editor\n\n';

  for (let i = 0; i < courses.length; i++) {
    const course = courses[i];
    const courseId = `course_${i + 1}`;

    // Inserir curso
    sql += `-- Curso: ${course.courseName}\n`;
    sql += `INSERT INTO public.courses (id, title, description, category, is_published, instructor_name)\n`;
    sql += `VALUES (\n`;
    sql += `  gen_random_uuid(),\n`;
    sql += `  '${escapeSQL(course.courseName)}',\n`;
    sql += `  'Curso importado do OneDrive',\n`;
    sql += `  'plataforma',\n`;
    sql += `  true,\n`;
    sql += `  'Instituto dos Sonhos'\n`;
    sql += `) RETURNING id INTO ${courseId};\n\n`;

    // Inserir módulos e aulas
    for (let j = 0; j < course.modules.length; j++) {
      const module = course.modules[j];
      const moduleId = `module_${i + 1}_${j + 1}`;

      sql += `-- Módulo: ${module.moduleName}\n`;
      sql += `INSERT INTO public.course_modules (id, title, description, course_id, order_index)\n`;
      sql += `SELECT gen_random_uuid(), '${escapeSQL(module.moduleName)}', '', c.id, ${j + 1}\n`;
      sql += `FROM public.courses c WHERE c.title = '${escapeSQL(course.courseName)}'\n`;
      sql += `RETURNING id INTO ${moduleId};\n\n`;

      // Inserir aulas
      for (let k = 0; k < module.lessons.length; k++) {
        const lesson = module.lessons[k];

        sql += `-- Aula: ${lesson.name}\n`;
        sql += `INSERT INTO public.lessons (title, description, module_id, video_url, order_index, duration_minutes)\n`;
        sql += `SELECT \n`;
        sql += `  '${escapeSQL(lesson.name.replace(/\.[^/.]+$/, ''))}',\n`; // Remove extensão
        sql += `  'Aula importada do OneDrive',\n`;
        sql += `  cm.id,\n`;
        sql += `  '${escapeSQL(lesson.url)}',\n`;
        sql += `  ${k + 1},\n`;
        sql += `  ${lesson.duration ? Math.round(lesson.duration / 60) : 0}\n`;
        sql += `FROM public.course_modules cm\n`;
        sql += `WHERE cm.title = '${escapeSQL(module.moduleName)}'\n`;
        sql += `  AND cm.course_id = (SELECT id FROM public.courses WHERE title = '${escapeSQL(course.courseName)}');\n\n`;
      }
    }

    sql += '\n';
  }

  return sql;
}

/**
 * Gera JSON estruturado
 */
function generateJSON(courses: CourseStructure[]): string {
  return JSON.stringify(courses, null, 2);
}

/**
 * Formata bytes para formato legível
 */
function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

/**
 * Escapa strings para SQL
 */
function escapeSQL(str: string): string {
  return str.replace(/'/g, "''");
}

/**
 * Função principal
 */
async function main() {
  console.log('🚀 Iniciando análise do OneDrive...\n');

  // Extrair ID da pasta
  const folderId = extractFolderIdFromUrl(ONEDRIVE_FOLDER_URL);
  if (!folderId) {
    console.error('❌ Não foi possível extrair o ID da pasta do URL');
    console.error('URL fornecido:', ONEDRIVE_FOLDER_URL);
    return;
  }

  console.log('📁 ID da pasta extraído:', folderId);

  // NOTA: Para usar este script, você precisa:
  // 1. Registrar um app no Azure AD
  // 2. Obter Client ID e Client Secret
  // 3. Configurar permissões do Microsoft Graph API
  // 4. Autenticar e obter access token

  console.log('\n⚠️  ATENÇÃO: Este script requer autenticação Microsoft Graph API');
  console.log('📖 Veja o arquivo GUIA_IMPORTACAO_ONEDRIVE.md para instruções completas\n');

  // Exemplo de como usar (requer configuração):
  /*
  const clientId = process.env.MICROSOFT_CLIENT_ID;
  const clientSecret = process.env.MICROSOFT_CLIENT_SECRET;
  const tenantId = process.env.MICROSOFT_TENANT_ID;

  const graphClient = Client.init({
    authProvider: async (done) => {
      // Implementar autenticação OAuth2
      const token = await getAccessToken(clientId, clientSecret, tenantId);
      done(null, token);
    },
  });

  const courses = await analyzeOneDriveStructure(graphClient, folderId);
  
  // Gerar relatórios
  console.log(generateTextReport(courses));
  
  // Salvar SQL
  const fs = require('fs');
  fs.writeFileSync('import-courses.sql', generateSQLImport(courses));
  
  // Salvar JSON
  fs.writeFileSync('courses-structure.json', generateJSON(courses));
  */
}

// Executar se chamado diretamente
if (require.main === module) {
  main().catch(console.error);
}

export {
  analyzeOneDriveStructure,
  generateTextReport,
  generateSQLImport,
  generateJSON,
  extractFolderIdFromUrl,
};

