# Check-up de arquitetura V1 — 2026-10-18

Base reconciliada: `cc6924a` (`master`), com trabalho V1 ainda não commitado neste worktree.

## Veredito

**ALINHADA PARA CONTINUAR EM ONDAS DEPENDENTES.** Não há segundo renderer, nem regra competitiva deslocada para a UI, nem caminho de Sandbox para deck/Canon. O próximo gate de produto é MM-06 em revisão humana; o próximo trabalho de backend é MM-07, condicionado às decisões operacionais já registradas.

## Limites arquiteturais verificados

| Limite | Evidência atual | Estado |
|---|---|---|
| Cliente/renderização | Godot em `scenes/` e `src/presentation/`; Web é export Godot; Capacitor apenas empacota `web/` | Conforme |
| Regras competitivas | `src/domain/duel_engine.gd`, validadores e RNG determinístico; UI envia/renderiza fluxo | Conforme |
| Contratos/dados | schemas versionados e fixtures Alpha; decks referenciam `card_id`/`edition_id` | Conforme |
| Sandbox/Canon | `SandboxForgeModel`/`SandboxForgeStore` persistem `sandbox-1` separado do perfil competitivo `local-1` | Conforme |
| Entrega Web/Android | um export Godot validado, PWA e sync Capacitor; não há renderer JS paralelo | Conforme |
| Serviço online/moderação | ainda não implementado; MM-07/MM-09 especificam fronteira autoritativa | Planejado, não alegar pronto |

## Correções aplicadas nesta revisão

1. O comando `npm test` agora cobre MM-04, MM-05, MM-06, navegação ART-002 e HUD ART-002.
2. Os workflows `godot-ci` e `web-delivery` agora executam MM-06, cena Forge e gates ART-002; Web delivery também valida o artefato PWA.
3. O roadmap registra MM-06 como **IN REVIEW**, não como NEXT: os gates técnicos passam, mas aceitação humana ainda falta.

## Evidência automatizada local

- MM-04: 194 checks, 0 falhas.
- MM-05: 94 checks, 0 falhas.
- MM-06: 14 checks, 0 falhas.
- ART-002 navegação: 21 checks, 0 falhas.
- ART-002 HUD: 19 checks, 0 falhas.
- Forge scene smoke e validação de artefato PWA executados com sucesso nesta sessão.

## Gaps reais antes de avançar o status

1. **MM-06:** aceitar visual/touch no Forge em alvo suportado.
2. **Android:** instalar JDK/Android SDK, compilar, instalar e testar o APK; sync Capacitor não prova APK.
3. **Abertura pública:** habilitar GitHub Private Vulnerability Reporting e publicar contato verificável de moderação/privacidade.
4. **MM-07–MM-09:** implementar somente um serviço autoritativo após confirmar operador, hospedagem e limites de retenção/abuso definidos nas specs.

## Próximo passo do roadmap

Após o aceite de MM-06, iniciar MM-07 com contratos de snapshot de submissão, transições fail-closed e histórico de auditoria. Não iniciar publicação Canon (MM-08) ou transporte online (MM-09) antes desse limite estar implementado e verificado.

