# CircadiaCare 🌙

**Plataforma de regulação circadiana baseada em dados fisiológicos**  
App iOS desenvolvido com SwiftUI + SwiftData, projetado para psiquiatras, biohackers e qualquer pessoa que queira otimizar sono e performance cognitiva.

---

## Visão Geral

CircadiaCare utiliza dados do Apple Watch / HealthKit para estimar o ritmo circadiano do usuário e oferece:

- **Score de Alinhamento Circadiano** diário (0–100)
- **Coaching personalizado** por cronotipo (luz, cafeína, exercício, sono)
- **Despertador Inteligente** que acorda na fase de sono leve
- **Previsão de janelas cognitivas** de alto desempenho
- **Histórico e tendências** semanais de sono

---

## Requisitos

| Item | Requisito |
|------|-----------|
| iOS  | 17.0+     |
| Xcode | 15.0+   |
| Swift | 5.9+    |
| Device | iPhone (funciona em iPad) |
| Apple Watch | Recomendado para dados automáticos |

---

## Setup do Projeto

### 1. Clone e Abra

```bash
git clone https://github.com/seu-usuario/CircadiaCare.git
cd CircadiaCare
open CircadiaCare.xcodeproj
```

### 2. Identifiers (obrigatório)

No Xcode → Target → Signing & Capabilities:
- Altere `Bundle Identifier` para o seu: ex. `br.seudominio.circadiacare`
- Selecione seu `Team` de desenvolvimento

### 3. Capabilities necessárias

Adicione no Xcode → Target → Signing & Capabilities:

| Capability | Motivo |
|------------|--------|
| HealthKit | Importação de dados de sono e FC |
| CloudKit | Sincronização entre dispositivos via iCloud |
| Push Notifications | Lembretes circadianos e despertador |
| Background Modes | `background-fetch` + `remote-notifications` |

### 4. CloudKit Container

- Crie o container `iCloud.br.com.circadiacare.app` no [Apple Developer Portal](https://developer.apple.com)
- Ou altere o nome do container em `CircadiaCareApp.swift` para o seu identificador

### 5. Assets.xcassets

Adicione obrigatoriamente:
- **AppIcon** — todos os tamanhos (use o gerador do Xcode ou [appicon.co](https://appicon.co))
- **LaunchLogo** — imagem SVG/PNG do logo para a launch screen
- **Cores do Design System** (veja abaixo)

### 6. Cores no Assets.xcassets

Crie Color Sets para cada cor listada em `Extensions/Color+App.swift`:

| Nome | Light | Dark |
|------|-------|------|
| appBackground | `#F2F0EC` | `#0D0D1A` |
| appCardBackground | `#FFFFFF` | `#1A1A2E` |
| appPrimary | `#1A1A2E` | `#F0F0FF` |
| appSecondaryText | `#6B7280` | `#9CA3AF` |
| appAccent | `#6366F1` | `#818CF8` |
| appSuccess | `#10B981` | `#34D399` |
| appWarning | `#F59E0B` | `#FBBF24` |
| appError | `#EF4444` | `#F87171` |
| appSeparator | `#E5E7EB` | `#2D2D44` |
| colorLight | `#F59E0B` | `#FBBF24` |
| colorCaffeine | `#92400E` | `#B45309` |
| colorExercise | `#10B981` | `#34D399` |
| colorSleep | `#6366F1` | `#818CF8` |
| colorCognitive | `#8B5CF6` | `#A78BFA` |
| colorNutrition | `#EF4444` | `#F87171` |

---

## Estrutura do Projeto

```
CircadiaCare/
├── CircadiaCareApp.swift          # Entry point @main, ModelContainer, notificações
├── ContentView.swift              # TabView raiz + lógica de onboarding
├── Info.plist                     # Permissões HealthKit, CloudKit, Push, deeplinks
│
├── Models/
│   ├── SleepEntry.swift           # @Model - registro de sono
│   ├── CircadianProfile.swift     # @Model - perfil + enums Chronotype, SubscriptionTier
│   ├── CoachingRecommendation.swift # @Model - recomendações diárias
│   ├── CircadianScore.swift       # @Model - score calculado
│   └── AppError.swift             # LocalizedError com todos os casos do app
│
├── ViewModels/
│   ├── DashboardViewModel.swift   # Score, janelas cognitivas, greeting
│   ├── SleepViewModel.swift       # Form de sono, importação HealthKit
│   ├── CoachingViewModel.swift    # Recomendações, filtros, progresso
│   └── ProfileViewModel.swift     # Edição de perfil, notificações
│
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift    # Tela principal
│   │   └── DashboardComponents.swift # ScoreCard, Chart, Clock, PeakWindow
│   ├── Sleep/
│   │   ├── SleepListView.swift    # Lista + stats semanais
│   │   ├── SleepDetailView.swift  # Detalhe com fases e FC
│   │   └── SleepFormView.swift    # Form + importação HealthKit
│   ├── Coaching/
│   │   ├── CoachingView.swift     # Lista de recomendações com filtros
│   │   └── CoachingDetailView.swift # Detalhe + contexto científico
│   ├── Profile/
│   │   ├── ProfileView.swift      # Perfil + configurações
│   │   ├── ProfileFormView.swift  # Form de edição
│   │   └── OnboardingView.swift   # 4 passos de onboarding
│   └── Shared/
│       ├── EmptyStateView.swift   # Estado vazio reutilizável
│       └── LoadingView.swift      # Loading overlay + inline
│
├── Services/
│   ├── HealthKitService.swift     # Actor - HealthKit integration
│   ├── CircadianScoringService.swift # Actor - algoritmo de score
│   ├── CoachingService.swift      # Actor - geração de recomendações
│   └── NotificationService.swift  # Actor - agendamento de notificações
│
└── Extensions/
    ├── Color+App.swift            # Design system de cores
    └── Date+Formatting.swift     # Helpers de formatação de datas
```

---

## Arquitetura

### MVVM com @Observable (Swift 5.9)

```
View (@State ViewModel)
  └── ViewModel (@Observable)
        └── Service (actor)
              └── Model (@Model SwiftData)
```

- **Views** nunca acessam Services diretamente
- **ViewModels** são `@Observable` (não `ObservableObject`)
- **Services** são `actor` — thread-safe por design
- **Dependency injection** via inicializadores (sem singletons)

### SwiftData

Todas as entidades persistíveis usam `@Model`. Queries reativas com `@Query` nas Views. CloudKit sync automático via `ModelConfiguration(.automatic)`.

### Concorrência

Zero uso de `DispatchQueue.main.async`. Todo código assíncrono usa `async/await`. Services são `actor` para isolamento de estado.

---

## Algoritmo de Score Circadiano

O score (0–100) é calculado com os seguintes pesos:

| Componente | Peso | Descrição |
|-----------|------|-----------|
| Alinhamento de sono | 35% | Diferença entre horário real e ideal para cronotipo |
| Consistência | 30% | Desvio padrão dos horários de dormir (7 dias) |
| Qualidade subjetiva | 20% | Score 1-10 informado pelo usuário |
| Duração | 15% | Proximidade de 7,5h de sono ideal |

---

## Cronotipos Suportados

| Tipo | Dormir Ideal | Acordar Ideal |
|------|-------------|---------------|
| Matutino Forte | 21h | 05h |
| Matutino Moderado | 22h | 06h |
| Intermediário | 23h | 07h |
| Vespertino Moderado | 00h | 08h |
| Vespertino Forte | 01h | 09h |

---

## Decisões de Arquitetura

**Por que SwiftData em vez de CoreData?**  
iOS 17+ target permite usar SwiftData nativamente com `@Model` macro, CloudKit sync automático e `@Query` reativo. Zero boilerplate.

**Por que `actor` nos Services?**  
HealthKit, notificações e cálculos de score são operações assíncronas que podem vir de múltiplas threads. `actor` garante exclusividade sem `DispatchQueue.main.async`.

**Por que sem dependências externas?**  
Zero dependências = zero riscos de supply chain, builds mais rápidos, e total controle para App Store review. Frameworks Apple são suficientes para 100% das funcionalidades.

**Por que `@Observable` em vez de `ObservableObject`?**  
`@Observable` (Swift 5.9) tem melhor performance por rastrear apenas propriedades acessadas, não recalcula views desnecessariamente, e é o padrão Apple atual.

---

## Roadmap

- [ ] Widget WidgetKit com score do dia
- [ ] App Intents / Siri Shortcuts ("Ei Siri, registrar meu sono")
- [ ] Apple Watch companion app
- [ ] Relatório semanal em PDF
- [ ] Integração Oura Ring / Whoop via exportação CSV
- [ ] Modo clínico para psiquiatras (múltiplos pacientes)
- [ ] ML local com Create ML para predição de cronotipo

---

## Licença

Propriedade intelectual de CircadiaCare. Todos os direitos reservados.
