const admin = require('firebase-admin');
const fs = require('fs');

// Carregar credenciais do Firebase
// Você precisa baixar a chave de serviço do Firebase Console
// Vá em: Configurações do Projeto > Contas de Serviço > Gerar nova chave privada
const serviceAccount = require('./serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'projeto-multi-plataforma'
});

const db = admin.firestore();

// Carregar dados do JSON
const data = JSON.parse(fs.readFileSync('firestore_import_data.json', 'utf8'));

async function importData() {
  console.log('🚀 Iniciando importação...\n');

  // Importar materiais
  if (data.materiais) {
    console.log('📦 Importando materiais...');
    for (const [docId, docData] of Object.entries(data.materiais)) {
      // Converter strings de data para Timestamp
      if (docData.criadoEm) {
        docData.criadoEm = admin.firestore.Timestamp.fromDate(new Date(docData.criadoEm));
      }
      if (docData.atualizadoEm) {
        docData.atualizadoEm = admin.firestore.Timestamp.fromDate(new Date(docData.atualizadoEm));
      }
      
      await db.collection('materiais').doc(docId).set(docData);
      console.log(`  ✅ ${docId}: ${docData.nome}`);
    }
    console.log(`✅ ${Object.keys(data.materiais).length} materiais importados\n`);
  }

  // Importar instrumentos
  if (data.instrumentos) {
    console.log('🔧 Importando instrumentos...');
    for (const [docId, docData] of Object.entries(data.instrumentos)) {
      // Converter strings de data para Timestamp
      if (docData.criadoEm) {
        docData.criadoEm = admin.firestore.Timestamp.fromDate(new Date(docData.criadoEm));
      }
      if (docData.atualizadoEm) {
        docData.atualizadoEm = admin.firestore.Timestamp.fromDate(new Date(docData.atualizadoEm));
      }
      if (docData.dataEmprestimo) {
        docData.dataEmprestimo = admin.firestore.Timestamp.fromDate(new Date(docData.dataEmprestimo));
      }
      if (docData.dataDevolucaoPrevista) {
        docData.dataDevolucaoPrevista = admin.firestore.Timestamp.fromDate(new Date(docData.dataDevolucaoPrevista));
      }
      
      await db.collection('instrumentos').doc(docId).set(docData);
      console.log(`  ✅ ${docId}: ${docData.nome}`);
    }
    console.log(`✅ ${Object.keys(data.instrumentos).length} instrumentos importados\n`);
  }

  // Importar alertas
  if (data.alertas) {
    console.log('⚠️ Importando alertas...');
    for (const [docId, docData] of Object.entries(data.alertas)) {
      // Converter strings de data para Timestamp
      if (docData.criadoEm) {
        docData.criadoEm = admin.firestore.Timestamp.fromDate(new Date(docData.criadoEm));
      }
      
      await db.collection('alertas').doc(docId).set(docData);
      console.log(`  ✅ ${docId}: ${docData.titulo}`);
    }
    console.log(`✅ ${Object.keys(data.alertas).length} alertas importados\n`);
  }

  // Importar usuários
  if (data.usuarios) {
    console.log('👤 Importando usuários...');
    for (const [docId, docData] of Object.entries(data.usuarios)) {
      // Converter strings de data para Timestamp
      if (docData.criadoEm) {
        docData.criadoEm = admin.firestore.Timestamp.fromDate(new Date(docData.criadoEm));
      }
      if (docData.atualizadoEm) {
        docData.atualizadoEm = admin.firestore.Timestamp.fromDate(new Date(docData.atualizadoEm));
      }
      
      await db.collection('usuarios').doc(docId).set(docData);
      console.log(`  ✅ ${docId}: ${docData.nome} (${docData.role})`);
    }
    console.log(`✅ ${Object.keys(data.usuarios).length} usuários importados\n`);
  }

  console.log('🎉 Importação concluída com sucesso!');
  process.exit(0);
}

importData().catch((error) => {
  console.error('❌ Erro ao importar:', error);
  process.exit(1);
});

