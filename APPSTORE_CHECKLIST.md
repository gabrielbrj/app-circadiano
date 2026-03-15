# Checklist de Submissão — App Store Connect
## CircadiaCare v1.0.0

Este checklist cobre tudo que precisa ser feito **manualmente** no Xcode e App Store Connect além do código gerado.

---

## 🔴 Obrigatório antes de Build

### Identidade do App
- [ ] Alterar `Bundle Identifier` no Target → `br.seudominio.circadiacare`
- [ ] Selecionar Team correto em Signing & Capabilities
- [ ] Provisioning Profile configurado (automático ou manual)
- [ ] Incrementar `CFBundleVersion` a cada build enviado

### Assets.xcassets — AppIcon
- [ ] Criar todos os tamanhos de AppIcon (usar [appicon.co](https://appicon.co) ou Xcode Image Set)
  - 1024×1024 (App Store, obrigatório)
  - 180×180 (iPhone @3x)
  - 120×120 (iPhone @2x)
  - 167×167 (iPad Pro @2x)
  - 152×152 (iPad @2x)
  - 76×76 (iPad @1x)
- [ ] Ícone sem cantos arredondados (iOS aplica automaticamente)
- [ ] Ícone sem transparência (fundo sólido obrigatório)
- [ ] Ícone não pode conter screenshots de outras plataformas

### Assets.xcassets — Cores
- [ ] Criar todos os Color Sets listados em `Color+App.swift` (Light + Dark variants)
  - appBackground, appCardBackground, appPrimary, appSecondaryText
  - appAccent, appSuccess, appWarning, appError, appSeparator
  - colorLight, colorCaffeine, colorExercise, colorSleep, colorCognitive, colorNutrition

### Assets.xcassets — Launch Screen
- [ ] Adicionar imagem `LaunchLogo` (logo do app, PNG 300×300+ ou SVG)
- [ ] Verificar que a cor `appBackground` está no Assets para o Launch Screen

---

## 🟡 Capabilities no Xcode

### Signing & Capabilities → Adicionar:
- [ ] **HealthKit** — ativar "Health Records" se aplicável
- [ ] **iCloud** — marcar "CloudKit" e adicionar container `iCloud.br.seudominio.circadiacare`
- [ ] **Push Notifications** — gerar certificado APNs no Developer Portal
- [ ] **Background Modes** — marcar: "Remote notifications" + "Background fetch"
- [ ] **Associated Domains** (opcional para deeplinks web → app)

---

## 🟡 App Store Connect — Configuração do App

### Informações Gerais
- [ ] Nome do app: "CircadiaCare" (máx 30 caracteres)
- [ ] Subtítulo: "Sono e Ritmo Circadiano" (máx 30 caracteres)
- [ ] Categoria primária: Health & Fitness
- [ ] Categoria secundária: Medical (dado o perfil da psiquiatra)
- [ ] Classificação etária: configurar questionário (app é 4+ ou 12+)
- [ ] Idiomas suportados: Português (Brasil) + English

### Texto da App Store (máx por campo)
- [ ] Descrição (4.000 chars): descrever funcionalidades + benefícios clínicos
- [ ] Novidades nesta versão: "Lançamento inicial do CircadiaCare"
- [ ] Palavras-chave (100 chars total): `sono,circadiano,cronobiologia,insônia,biohacker,despertador,saúde`
- [ ] URL de suporte (obrigatório): criar página de suporte
- [ ] URL de marketing (opcional)
- [ ] URL de política de privacidade (OBRIGATÓRIO para apps com dados de saúde)

### Screenshots obrigatórias
- [ ] iPhone 6.9" (iPhone 16 Pro Max) — mínimo 3 screenshots
- [ ] iPhone 6.5" (iPhone 14 Plus) — ou use mesmas do 6.9"
- [ ] iPad 13" Pro — se suporte a iPad declarado
- [ ] Formato: PNG/JPEG, sem borda de dispositivo obrigatória

### Informações de Revisão
- [ ] Notas para revisão Apple (opcional mas recomendado): explicar uso do HealthKit
- [ ] Conta de demonstração (se app tem login/auth)
- [ ] Número de telefone de contato

---

## 🟡 Privacidade e Compliance

### Privacy Nutrition Labels (App Store Connect → App Privacy)
- [ ] Declarar coleta de dados de saúde e aptidão física
- [ ] Declarar dados de uso (se houver analytics)
- [ ] Declarar identificadores (se houver)
- [ ] Health & Fitness data: "Data Not Linked to You" ou "Data Linked to You"

### Política de Privacidade (OBRIGATÓRIO)
- [ ] Criar página web com política de privacidade completa
- [ ] Mencionar explicitamente: HealthKit, iCloud, dados de sono, dados biométricos
- [ ] Incluir: direitos do usuário (LGPD), retenção de dados, compartilhamento com terceiros
- [ ] URL da política no App Store Connect E no Info.plist

### LGPD (Lei Geral de Proteção de Dados — Brasil)
- [ ] Informar finalidade do uso dos dados de saúde
- [ ] Garantir que dados HealthKit não são enviados a servidores (atualmente não são)
- [ ] Providenciar mecanismo de exclusão de dados do usuário

---

## 🟡 In-App Purchases (Assinatura Premium)

- [ ] Criar produto de assinatura em App Store Connect → Monetization → Subscriptions
- [ ] Tipo: Auto-Renewable Subscription
- [ ] Grupo: "CircadiaCare Premium"
- [ ] Preços sugeridos:
  - Mensal: BRL 39,90 / USD 6,99
  - Anual: BRL 299,90 / USD 49,99 (2 meses grátis)
- [ ] Implementar `StoreKit 2` no app para purchase flow
- [ ] Adicionar "Restore Purchases" button
- [ ] Servidor de validação de recibo (ou usar server notifications)
- [ ] Tela de paywall com descrição clara dos benefícios

---

## 🟡 HealthKit — Revisão Apple

O HealthKit tem revisão rigorosa. Garantir:
- [ ] `NSHealthShareUsageDescription` explica CLARAMENTE o benefício ao usuário
- [ ] O app só solicita permissão quando o usuário tenta usar a feature
- [ ] Não solicitar dados de saúde que não são usados (violação imediata)
- [ ] Dados HealthKit não são enviados para servidores de terceiros sem consentimento explícito
- [ ] Preparar documentação explicando uso clínico (para revisão Apple)

---

## 🟢 Opcional mas Recomendado

### Performance e Qualidade
- [ ] Testar em dispositivo físico (não só Simulator)
- [ ] Testar Dark Mode em todos os screens
- [ ] Testar Dynamic Type nas configurações de acessibilidade (tamanho extra grande)
- [ ] Testar VoiceOver nos fluxos principais
- [ ] Testar com iPad (layout adaptativo)
- [ ] Instruments → Profiler: verificar memory leaks e CPU spikes

### Internacionalização
- [ ] Criar `Localizable.xcstrings` com todas as strings do app
- [ ] Adicionar tradução em inglês (aumenta mercado global)
- [ ] Testar com idioma do sistema em inglês

### Crashlytics / Analytics
- [ ] Firebase Crashlytics (se optar por analytics)
- [ ] OU usar MetricKit nativo (sem dependências externas)
- [ ] Testar crash reporting antes de submissão

---

## 🔵 Processo de Submissão

1. Product → Archive no Xcode
2. Distribute App → App Store Connect
3. App Store Connect → Criar nova versão
4. Preencher todos os campos obrigatórios
5. Selecionar build enviado
6. Submit for Review
7. Aguardar 1-3 dias úteis (ou usar TestFlight primeiro)

---

## 📋 Resumo de Status

| Área | Status |
|------|--------|
| Código SwiftUI | ✅ Gerado |
| Arquitetura MVVM | ✅ Implementada |
| SwiftData + CloudKit | ✅ Configurado |
| HealthKit Integration | ✅ Implementado |
| Notificações Push | ✅ Implementado |
| AppIcon | ⚠️ Precisa criar artes |
| Assets de Cores | ⚠️ Precisa criar no Xcode |
| In-App Purchase | ⚠️ Precisa implementar StoreKit 2 |
| Política de Privacidade | ⚠️ Precisa criar página web |
| Screenshots App Store | ⚠️ Precisa capturar |
| Localization strings | ⚠️ Precisa criar .xcstrings |
