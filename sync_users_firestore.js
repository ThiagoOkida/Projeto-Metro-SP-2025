const admin = require('firebase-admin');
const fs = require('fs');

// Carregar credenciais do Firebase
const serviceAccount = require('./serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'projeto-multi-plataforma'
});

const auth = admin.auth();
const db = admin.firestore();

// Carregar dados do JSON
const data = JSON.parse(fs.readFileSync('firestore_import_data.json', 'utf8'));

async function syncUsers() {
  console.log('🔄 Sincronizando usuários do Firebase Auth com Firestore...\n');

  if (!data.usuarios) {
    console.log('❌ Nenhum usuário encontrado no JSON');
    return;
  }

  // Mapear emails para dados do JSON
  const usersMap = {};
  for (const [docId, userData] of Object.entries(data.usuarios)) {
    usersMap[userData.email] = userData;
  }

  // Buscar todos os usuários do Auth e criar/atualizar no Firestore
  for (const [email, userData] of Object.entries(usersMap)) {
    try {
      // Buscar usuário no Firebase Auth pelo email
      const userRecord = await auth.getUserByEmail(email);
      
      console.log(`✅ Usuário encontrado no Auth: ${email}`);
      console.log(`   UID: ${userRecord.uid}`);

      // Preparar dados do documento (sem password)
      const userDocData = {
        nome: userData.nome,
        email: userData.email,
        role: userData.role,
        ativo: userData.ativo ?? true,
        localizacao: userData.localizacao || null,
        telefone: userData.telefone || null,
        criadoEm: admin.firestore.Timestamp.fromDate(new Date(userData.criadoEm)),
        atualizadoEm: admin.firestore.Timestamp.fromDate(new Date(userData.atualizadoEm)),
      };

      // Criar/atualizar documento no Firestore usando o UID do Auth como ID
      await db.collection('usuarios').doc(userRecord.uid).set(userDocData);
      console.log(`✅ Documento criado/atualizado no Firestore: ${userData.nome} (${userData.role})\n`);

      // Deletar documentos antigos se existirem (admin_001, gestor_001, etc)
      const oldDocIds = ['admin_001', 'gestor_001', 'contribuinte_001'];
      for (const oldDocId of oldDocIds) {
        const oldDoc = await db.collection('usuarios').doc(oldDocId).get();
        if (oldDoc.exists && oldDoc.data().email === email) {
          await db.collection('usuarios').doc(oldDocId).delete();
          console.log(`🗑️  Documento antigo removido: ${oldDocId}`);
        }
      }
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        console.log(`⚠️  Usuário não encontrado no Auth: ${email}`);
        console.log(`   → Crie este usuário no Firebase Console primeiro!\n`);
      } else {
        console.error(`❌ Erro ao processar ${email}:`, error.message);
      }
    }
  }

  console.log('\n🎉 Sincronização concluída!');
  console.log('\n📋 Resumo:');
  console.log('   - Documentos no Firestore agora usam os UIDs do Firebase Auth');
  console.log('   - Documentos antigos (admin_001, etc) foram removidos');
  console.log('   - Agora você pode fazer login no app!\n');
  process.exit(0);
}

syncUsers().catch((error) => {
  console.error('❌ Erro:', error);
  process.exit(1);
});

