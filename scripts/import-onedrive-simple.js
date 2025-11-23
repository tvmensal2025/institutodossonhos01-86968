/**
 * Script simples para importar cursos do OneDrive
 * 
 * Este script usa uma abordagem mais simples: você fornece a estrutura
 * manualmente e ele gera o SQL de importação.
 * 
 * USO:
 * 1. Edite a constante COURSES_STRUCTURE abaixo com seus cursos
 * 2. Execute: node scripts/import-onedrive-simple.js
 * 3. Copie o SQL gerado e execute no Supabase
 */

const COURSES_STRUCTURE = [
  {
    courseName: 'Nome do Curso 1',
    description: 'Descrição do curso 1',
    category: 'plataforma', // 'plataforma', 'exercicios', 'doces'
    instructor: 'Instituto dos Sonhos',
    modules: [
      {
        moduleName: 'Módulo 1',
        description: 'Descrição do módulo 1',
        lessons: [
          {
            title: 'Aula 1',
            description: 'Descrição da aula 1',
            videoUrl: 'https://acadcruzeirodosul-my.sharepoint.com/.../Aula1.mp4',
            durationMinutes: 30, // Opcional
          },
          {
            title: 'Aula 2',
            description: 'Descrição da aula 2',
            videoUrl: 'https://acadcruzeirodosul-my.sharepoint.com/.../Aula2.mp4',
            durationMinutes: 25,
          },
        ],
      },
      {
        moduleName: 'Módulo 2',
        description: 'Descrição do módulo 2',
        lessons: [
          {
            title: 'Aula 1',
            description: 'Descrição da aula 1',
            videoUrl: 'https://acadcruzeirodosul-my.sharepoint.com/.../Aula1.mp4',
            durationMinutes: 20,
          },
        ],
      },
    ],
  },
  // Adicione mais cursos aqui...
];

/**
 * Escapa strings para SQL
 */
function escapeSQL(str) {
  if (!str) return '';
  return str.replace(/'/g, "''");
}

/**
 * Gera SQL para importar cursos
 */
function generateImportSQL(courses) {
  let sql = '-- SQL gerado automaticamente para importar cursos do OneDrive\n';
  sql += '-- Execute este script no Supabase SQL Editor\n\n';
  sql += 'BEGIN;\n\n';

  courses.forEach((course, courseIndex) => {
    // Inserir curso
    sql += `-- ============================================\n`;
    sql += `-- CURSO: ${course.courseName}\n`;
    sql += `-- ============================================\n\n`;
    
    sql += `INSERT INTO public.courses (\n`;
    sql += `  title,\n`;
    sql += `  description,\n`;
    sql += `  category,\n`;
    sql += `  is_published,\n`;
    sql += `  instructor_name,\n`;
    sql += `  created_at\n`;
    sql += `) VALUES (\n`;
    sql += `  '${escapeSQL(course.courseName)}',\n`;
    sql += `  '${escapeSQL(course.description || '')}',\n`;
    sql += `  '${escapeSQL(course.category || 'plataforma')}',\n`;
    sql += `  true,\n`;
    sql += `  '${escapeSQL(course.instructor || 'Instituto dos Sonhos')}',\n`;
    sql += `  now()\n`;
    sql += `) RETURNING id as course_${courseIndex + 1}_id;\n\n`;

    // Inserir módulos e aulas
    course.modules.forEach((module, moduleIndex) => {
      sql += `-- Módulo: ${module.moduleName}\n`;
      sql += `INSERT INTO public.course_modules (\n`;
      sql += `  title,\n`;
      sql += `  description,\n`;
      sql += `  course_id,\n`;
      sql += `  order_index,\n`;
      sql += `  created_at\n`;
      sql += `) SELECT \n`;
      sql += `  '${escapeSQL(module.moduleName)}',\n`;
      sql += `  '${escapeSQL(module.description || '')}',\n`;
      sql += `  c.id,\n`;
      sql += `  ${moduleIndex + 1},\n`;
      sql += `  now()\n`;
      sql += `FROM public.courses c\n`;
      sql += `WHERE c.title = '${escapeSQL(course.courseName)}'\n`;
      sql += `RETURNING id as module_${courseIndex + 1}_${moduleIndex + 1}_id;\n\n`;

      // Inserir aulas
      module.lessons.forEach((lesson, lessonIndex) => {
        sql += `-- Aula: ${lesson.title}\n`;
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
        sql += `  '${escapeSQL(lesson.description || '')}',\n`;
        sql += `  cm.id,\n`;
        sql += `  '${escapeSQL(lesson.videoUrl)}',\n`;
        sql += `  ${lessonIndex + 1},\n`;
        sql += `  ${lesson.durationMinutes || 0},\n`;
        sql += `  now()\n`;
        sql += `FROM public.course_modules cm\n`;
        sql += `WHERE cm.title = '${escapeSQL(module.moduleName)}'\n`;
        sql += `  AND cm.course_id = (\n`;
        sql += `    SELECT id FROM public.courses WHERE title = '${escapeSQL(course.courseName)}'\n`;
        sql += `  );\n\n`;
      });
    });

    sql += '\n';
  });

  sql += 'COMMIT;\n';
  sql += '\n-- Verificar importação\n';
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

/**
 * Função principal
 */
function main() {
  console.log('🚀 Gerando SQL de importação...\n');

  if (COURSES_STRUCTURE.length === 0) {
    console.log('⚠️  Nenhum curso encontrado na estrutura.');
    console.log('📝 Edite a constante COURSES_STRUCTURE no arquivo e adicione seus cursos.\n');
    return;
  }

  const sql = generateImportSQL(COURSES_STRUCTURE);

  // Salvar em arquivo
  const fs = require('fs');
  const path = require('path');
  const outputPath = path.join(__dirname, '..', 'import-courses-onedrive.sql');
  
  fs.writeFileSync(outputPath, sql, 'utf8');
  
  console.log(`✅ SQL gerado com sucesso!`);
  console.log(`📄 Arquivo salvo em: ${outputPath}\n`);
  console.log(`📊 Resumo:`);
  console.log(`   - Cursos: ${COURSES_STRUCTURE.length}`);
  
  const totalModules = COURSES_STRUCTURE.reduce((sum, course) => sum + course.modules.length, 0);
  const totalLessons = COURSES_STRUCTURE.reduce(
    (sum, course) => sum + course.modules.reduce((mSum, module) => mSum + module.lessons.length, 0),
    0
  );
  
  console.log(`   - Módulos: ${totalModules}`);
  console.log(`   - Aulas: ${totalLessons}\n`);
  console.log(`📋 Próximos passos:`);
  console.log(`   1. Revise o arquivo ${outputPath}`);
  console.log(`   2. Ajuste se necessário (categorias, descrições, etc.)`);
  console.log(`   3. Execute no Supabase SQL Editor\n`);
}

// Executar
if (require.main === module) {
  main();
}

module.exports = { generateImportSQL, COURSES_STRUCTURE };

