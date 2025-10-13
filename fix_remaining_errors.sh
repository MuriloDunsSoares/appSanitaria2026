#!/bin/bash

# Script para corrigir erros comuns de Map → Entity

echo "🔧 Corrigindo user['id'] → user.id..."
find lib/presentation/screens -name "*.dart" -type f -exec sed -i '' "s/user\['id'\]/user.id/g" {} \;
find lib/presentation/screens -name "*.dart" -type f -exec sed -i '' "s/user\['nome'\]/user.nome/g" {} \;
find lib/presentation/screens -name "*.dart" -type f -exec sed -i '' "s/user\['email'\]/user.email/g" {} \;
find lib/presentation/screens -name "*.dart" -type f -exec sed -i '' "s/user\['tipo'\]/user.tipo/g" {} \;
find lib/presentation/screens -name "*.dart" -type f -exec sed -i '' "s/user\['telefone'\]/user.telefone/g" {} \;

echo "✅ Correções de Map → Entity aplicadas!"
