/**
 * Script para configurar permissões do OneDrive/SharePoint
 * 
 * Este script configura todas as pastas e vídeos para "Qualquer pessoa com o link pode visualizar"
 * 
 * PRÉ-REQUISITOS:
 * 1. App registrado no Azure AD
 * 2. Permissões: Files.ReadWrite.All, Sites.ReadWrite.All
 * 3. Variáveis de ambiente configuradas
 * 
 * USO:
 * 1. Configure as variáveis de ambiente
 * 2. Execute: npx ts-node scripts/configure-onedrive-permissions.ts
 */

import { Client } from '@microsoft/microsoft-graph-client';
import 'isomorphic-fetch';

const ONEDRIVE_FOLDER_URL = 'https://acadcruzeirodosul-my.sharepoint.com/:f:/g/personal/rafael_dias993_cs_ceunsp_edu_br/IgAz3pLjixnLRa1HFKQCkrTTAZpNqnlhrva_cwlScOZsmu0?e=3SxAaJ';

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
  permissions?: any[];
}

/**
 * Extrai o ID da pasta do URL
 */
function extractFolderIdFromUrl(url: string): string | null {
  try {
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
 * Configura permissões para um item (pasta ou arquivo)
 */
async function setPublicPermissions(
  graphClient: Client,
  itemId: string,
  itemName: string
): Promise<boolean> {
  try {
    // Criar link de compartilhamento público
    const permission = await graphClient
      .api(`/sites/root/drive/items/${itemId}/createLink`)
      .post({
        type: 'view', // 'view' permite visualização sem edição
        scope: 'anonymous', // 'anonymous' = qualquer pessoa com o link
      });

    console.log(`✅ Permissões configuradas: ${itemName}`);
    return true;
  } catch (error: any) {
    console.error(`❌ Erro ao configurar ${itemName}:`, error.message);
    return false;
  }
}

/**
 * Processa recursivamente todas as pastas e arquivos
 */
async function processFolderRecursively(
  graphClient: Client,
  folderId: string,
  folderPath: string = ''
): Promise<{
  foldersProcessed: number;
  filesProcessed: number;
  errors: number;
}> {
  let foldersProcessed = 0;
  let filesProcessed = 0;
  let errors = 0;

  try {
    // Configurar permissões da pasta atual
    console.log(`📁 Processando pasta: ${folderPath || 'Raiz'}`);
    const folderItem = await graphClient
      .api(`/sites/root/drive/items/${folderId}`)
      .get();
    
    const folderPermSuccess = await setPublicPermissions(
      graphClient,
      folderId,
      folderItem.name
    );
    if (!folderPermSuccess) errors++;

    // Listar itens dentro da pasta
    const items = await graphClient
      .api(`/sites/root/drive/items/${folderId}/children`)
      .get();

    for (const item of items.value as OneDriveItem[]) {
      const itemPath = `${folderPath}/${item.name}`;

      if (item.folder) {
        // É uma pasta - processar recursivamente
        foldersProcessed++;
        const result = await processFolderRecursively(
          graphClient,
          item.id,
          itemPath
        );
        foldersProcessed += result.foldersProcessed;
        filesProcessed += result.filesProcessed;
        errors += result.errors;
      } else if (item.file) {
        // É um arquivo - configurar permissões
        filesProcessed++;
        const filePermSuccess = await setPublicPermissions(
          graphClient,
          item.id,
          itemPath
        );
        if (!filePermSuccess) errors++;
        
        // Pequeno delay para não sobrecarregar a API
        await new Promise(resolve => setTimeout(resolve, 500));
      }
    }
  } catch (error: any) {
    console.error(`❌ Erro ao processar pasta ${folderPath}:`, error.message);
    errors++;
  }

  return { foldersProcessed, filesProcessed, errors };
}

/**
 * Função principal
 */
async function main() {
  console.log('🚀 Iniciando configuração de permissões do OneDrive...\n');

  const folderId = extractFolderIdFromUrl(ONEDRIVE_FOLDER_URL);
  if (!folderId) {
    console.error('❌ Não foi possível extrair o ID da pasta');
    return;
  }

  console.log(`📁 ID da pasta: ${folderId}\n`);

  // NOTA: Este script requer autenticação Microsoft Graph API
  // Veja GUIA_CONFIGURACAO_PERMISSOES.md para instruções completas

  console.log('⚠️  Este script requer autenticação Microsoft Graph API');
  console.log('📖 Veja GUIA_CONFIGURACAO_PERMISSOES.md para instruções\n');

  // Exemplo de uso (requer configuração):
  /*
  const graphClient = Client.init({
    authProvider: async (done) => {
      const token = await getAccessToken();
      done(null, token);
    },
  });

  const result = await processFolderRecursively(graphClient, folderId);
  
  console.log('\n📊 Resumo:');
  console.log(`   ✅ Pastas processadas: ${result.foldersProcessed}`);
  console.log(`   ✅ Arquivos processados: ${result.filesProcessed}`);
  console.log(`   ❌ Erros: ${result.errors}`);
  */
}

if (require.main === module) {
  main().catch(console.error);
}

export { processFolderRecursively, setPublicPermissions, extractFolderIdFromUrl };

