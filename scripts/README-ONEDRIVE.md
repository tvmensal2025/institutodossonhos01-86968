# 📥 Scripts de Importação do OneDrive

Este diretório contém scripts para analisar e importar cursos do OneDrive/SharePoint.

---

## 📁 **Arquivos**

### **1. `import-onedrive-simple.js`** ⭐ RECOMENDADO PARA COMEÇAR

Script mais simples que não requer autenticação. Você fornece a estrutura manualmente.

**Como usar:**
1. Abra o arquivo `import-onedrive-simple.js`
2. Edite a constante `COURSES_STRUCTURE` com seus cursos
3. Execute: `node scripts/import-onedrive-simple.js`
4. Copie o SQL gerado e execute no Supabase

**Vantagens:**
- ✅ Não requer autenticação
- ✅ Simples de usar
- ✅ Controle total sobre os dados

**Desvantagens:**
- ⚠️ Requer entrada manual dos dados

---

### **2. `analyze-onedrive-courses.ts`** (Avançado)

Script automatizado que conecta ao OneDrive via Microsoft Graph API.

**Como usar:**
1. Configure autenticação Microsoft (veja `GUIA_IMPORTACAO_ONEDRIVE.md`)
2. Execute: `npx ts-node scripts/analyze-onedrive-courses.ts`
3. O script gera automaticamente:
   - Relatório em texto
   - SQL de importação
   - JSON estruturado

**Vantagens:**
- ✅ Totalmente automatizado
- ✅ Analisa estrutura automaticamente
- ✅ Gera múltiplos formatos de saída

**Desvantagens:**
- ⚠️ Requer configuração de autenticação
- ⚠️ Mais complexo de configurar

---

## 🚀 **Quick Start (Método Simples)**

### **Passo 1: Acessar OneDrive**

1. Abra o link: https://acadcruzeirodosul-my.sharepoint.com/:f:/g/personal/rafael_dias993_cs_ceunsp_edu_br/IgAz3pLjixnLRa1HFKQCkrTTAb5rCPJ7HqxF_mOIb6Dli6g?e=08PdvC

2. Navegue pela estrutura:
   - Anote os nomes dos cursos (pastas principais)
   - Anote os nomes dos módulos (subpastas)
   - Para cada vídeo, copie o link de compartilhamento

### **Passo 2: Editar Script**

Abra `scripts/import-onedrive-simple.js` e edite:

```javascript
const COURSES_STRUCTURE = [
  {
    courseName: 'Nome do Curso',
    description: 'Descrição',
    category: 'plataforma',
    instructor: 'Instituto dos Sonhos',
    modules: [
      {
        moduleName: 'Módulo 1',
        description: 'Descrição do módulo',
        lessons: [
          {
            title: 'Aula 1',
            description: 'Descrição da aula',
            videoUrl: 'https://acadcruzeirodosul-my.sharepoint.com/...',
            durationMinutes: 30,
          },
        ],
      },
    ],
  },
];
```

### **Passo 3: Executar**

```bash
node scripts/import-onedrive-simple.js
```

### **Passo 4: Importar no Supabase**

1. Abra o arquivo `import-courses-onedrive.sql` gerado
2. Revise o conteúdo
3. Acesse Supabase → SQL Editor
4. Cole e execute o SQL

---

## 📋 **Estrutura de Dados**

### **Formato do JSON/JavaScript:**

```javascript
{
  courseName: 'Nome do Curso',        // Nome do curso
  description: 'Descrição...',        // Descrição (opcional)
  category: 'plataforma',              // 'plataforma', 'exercicios', 'doces'
  instructor: 'Instituto dos Sonhos',  // Nome do instrutor
  modules: [                           // Array de módulos
    {
      moduleName: 'Módulo 1',         // Nome do módulo
      description: 'Descrição...',     // Descrição (opcional)
      lessons: [                       // Array de aulas
        {
          title: 'Aula 1',            // Título da aula
          description: 'Descrição...', // Descrição (opcional)
          videoUrl: 'https://...',     // URL do vídeo no OneDrive
          durationMinutes: 30,         // Duração em minutos (opcional)
        },
      ],
    },
  ],
}
```

---

## 🔗 **Obter Links dos Vídeos no OneDrive**

### **Método 1: Link de Compartilhamento**

1. Clique com botão direito no vídeo
2. Selecione **"Compartilhar"**
3. Configure como **"Qualquer pessoa com o link pode visualizar"**
4. Copie o link

### **Método 2: Link Direto**

1. Clique com botão direito no vídeo
2. Selecione **"Copiar link"** ou **"Obter link"**
3. O link será algo como:
   ```
   https://acadcruzeirodosul-my.sharepoint.com/:v:/g/personal/.../VIDEO.mp4?e=...
   ```

### **Método 3: Link de Embed (Opcional)**

Para melhor compatibilidade, você pode converter para formato de visualização:
```
https://acadcruzeirodosul-my.sharepoint.com/:v:/g/personal/.../VIDEO.mp4?e=...
```
A plataforma detecta automaticamente e converte para embed quando possível.

---

## ✅ **Verificar Importação**

Após importar, execute no Supabase:

```sql
-- Ver todos os cursos
SELECT 
  id,
  title,
  category,
  is_published,
  created_at
FROM public.courses
ORDER BY created_at DESC;

-- Ver estrutura completa
SELECT 
  c.title as curso,
  cm.title as modulo,
  l.title as aula,
  l.video_url,
  l.duration_minutes
FROM public.courses c
LEFT JOIN public.course_modules cm ON cm.course_id = c.id
LEFT JOIN public.lessons l ON l.module_id = cm.id
ORDER BY c.title, cm.order_index, l.order_index;

-- Estatísticas
SELECT 
  COUNT(DISTINCT c.id) as total_cursos,
  COUNT(DISTINCT cm.id) as total_modulos,
  COUNT(DISTINCT l.id) as total_aulas
FROM public.courses c
LEFT JOIN public.course_modules cm ON cm.course_id = c.id
LEFT JOIN public.lessons l ON l.module_id = cm.id;
```

---

## 🐛 **Problemas Comuns**

### **Erro: "Cannot find module"**

**Solução**: Instale as dependências:
```bash
npm install
```

### **Erro: "SQL syntax error"**

**Solução**: 
- Verifique se os nomes não contêm caracteres especiais problemáticos
- Use aspas simples corretamente
- Verifique se todas as strings estão escapadas

### **Vídeos não aparecem na plataforma**

**Solução**:
- Verifique se os links estão corretos
- Confirme que os vídeos estão compartilhados publicamente
- Teste os links manualmente no navegador
- Verifique se a plataforma suporta o formato do link (veja `GUIA_VIDEOS_GOOGLE_DRIVE.md`)

---

## 📚 **Documentação Relacionada**

- `GUIA_IMPORTACAO_ONEDRIVE.md` - Guia completo de importação
- `GUIA_VIDEOS_GOOGLE_DRIVE.md` - Suporte a vídeos do OneDrive/Google Drive

---

## 💡 **Dicas**

1. **Comece pequeno**: Teste com 1 curso antes de importar tudo
2. **Faça backup**: Sempre faça backup do banco antes de importar
3. **Revise URLs**: Verifique se os links estão corretos e acessíveis
4. **Organize**: Mantenha a estrutura de pastas organizada no OneDrive
5. **Documente**: Anote mudanças para referência futura

---

**Última atualização**: Novembro 2024

