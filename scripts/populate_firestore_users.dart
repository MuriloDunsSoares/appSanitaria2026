/// Script para popular Firestore com dados de usuários do Firebase Auth
/// 
/// Uso: dart run scripts/populate_firestore_users.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  print('🔥 Iniciando script de população do Firestore...\n');

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // Lista de usuários para criar no Firestore
  // IMPORTANTE: Use os UIDs corretos do Firebase Authentication
  final users = [
    {
      'uid': 'sLrYoCGio6arsQPNh4cYVCRE...',  // Marcio (já existe)
      'email': 'marcio@gmail.com',
      'nome': 'Marcio',
      'tipo': 'profissional',
      'telefone': '(11) 98765-4321',
      'cpf': '123.456.789-01',
      'cidade': 'São Paulo',
      'estado': 'SP',
      'dataNascimento': '1985-05-15',
      'especialidade': 'cuidadores',
      'bio': 'Profissional experiente em cuidados',
      'precoHora': 50.0,
      'avaliacao': 0.0,
    },
    {
      'uid': 'YAa8VJ2lkQfGkfl6hQtshyeW2...',  // Tiago
      'email': 'tiago@gmail.com',
      'nome': 'Tiago',
      'tipo': 'paciente',
      'telefone': '(11) 91234-5678',
      'cpf': '234.567.890-12',
      'cidade': 'Rio de Janeiro',
      'estado': 'RJ',
      'dataNascimento': '1990-03-20',
    },
    {
      'uid': 'NUMVVu40f4MfkvKhhrd7cYA...',  // Eduarda
      'email': 'eduarda@gmail.com',
      'nome': 'Eduarda',
      'tipo': 'profissional',
      'telefone': '(21) 98765-1234',
      'cpf': '345.678.901-23',
      'cidade': 'Belo Horizonte',
      'estado': 'MG',
      'dataNascimento': '1988-07-10',
      'especialidade': 'enfermeiros',
      'bio': 'Enfermeira com 10 anos de experiência',
      'precoHora': 70.0,
      'avaliacao': 0.0,
    },
    {
      'uid': 'Om2OJvCeELcntuqJietW1x9v...',  // Maria
      'email': 'maria@gmail.com',
      'nome': 'Maria',
      'tipo': 'paciente',
      'telefone': '(31) 91234-9876',
      'cpf': '456.789.012-34',
      'cidade': 'Curitiba',
      'estado': 'PR',
      'dataNascimento': '1975-11-25',
    },
    {
      'uid': '7RMCuaRhBUfFuTnaQQPP7k2...',  // Ivan
      'email': 'ivan@gmail.com',
      'nome': 'Ivan',
      'tipo': 'profissional',
      'telefone': '(41) 98765-5432',
      'cpf': '567.890.123-45',
      'cidade': 'Porto Alegre',
      'estado': 'RS',
      'dataNascimento': '1992-01-15',
      'especialidade': 'fisioterapeutas',
      'bio': 'Fisioterapeuta especializado em reabilitação',
      'precoHora': 80.0,
      'avaliacao': 0.0,
    },
    {
      'uid': 'HWNpvCLgNieML28XnLTsHX...',  // Murilo
      'email': 'murilo@gmail.com',
      'nome': 'Murilo',
      'tipo': 'paciente',
      'telefone': '(51) 91234-6789',
      'cpf': '678.901.234-56',
      'cidade': 'Salvador',
      'estado': 'BA',
      'dataNascimento': '1980-09-30',
    },
    {
      'uid': '2owgi92mSbS3q2lZk8cr05Wl...',  // GBTC
      'email': 'gbtc@gmail.com',
      'nome': 'Gabriel',
      'tipo': 'profissional',
      'telefone': '(71) 98765-9876',
      'cpf': '789.012.345-67',
      'cidade': 'Fortaleza',
      'estado': 'CE',
      'dataNascimento': '1987-12-05',
      'especialidade': 'medicos',
      'bio': 'Médico clínico geral',
      'precoHora': 120.0,
      'avaliacao': 0.0,
    },
  ];

  print('📋 Criando ${users.length} usuários no Firestore...\n');

  for (final user in users) {
    final uid = user['uid'] as String;
    final email = user['email'] as String;
    
    try {
      // Verificar se já existe
      final doc = await firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        print('⏭️  $email já existe no Firestore (pulando)');
        continue;
      }

      // Criar dados base
      final userData = {
        'id': uid,
        'email': email,
        'nome': user['nome'],
        'tipo': user['tipo'],
        'telefone': user['telefone'],
        'cpf': user['cpf'],
        'cidade': user['cidade'],
        'estado': user['estado'],
        'dataNascimento': user['dataNascimento'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Adicionar campos específicos de profissionais
      if (user['tipo'] == 'profissional') {
        userData['especialidade'] = user['especialidade'];
        userData['bio'] = user['bio'];
        userData['precoHora'] = user['precoHora'];
        userData['avaliacao'] = user['avaliacao'];
      }

      // Criar documento
      await firestore.collection('users').doc(uid).set(userData);
      
      print('✅ $email criado com sucesso no Firestore');
    } catch (e) {
      print('❌ Erro ao criar $email: $e');
    }
  }

  print('\n🎉 Script concluído!');
  print('Agora você pode fazer login com todas as contas.');
}

