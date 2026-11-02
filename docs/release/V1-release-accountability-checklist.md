# V1 release accountability checklist

Nenhum item pode ser marcado somente por intenção ou por CI parcial. Registre commit, responsável e evidência verificável.

## Responsáveis do beta fechado

- Operador e responsável de release: az1nn / Mememom.
- Moderação: moderador e administrador; o administrador faz escalonamento e apelação quando disponível.
- Incidente, privacidade e segurança: operador do beta pelo canal privado fornecido aos participantes.

## Gates técnicos

- [x] Suites MM-04 a MM-09 passam no mesmo commit exato. Evidência: [V1 verification report (2026-10-20)](../reports/V1-verification-2026-10-20.md).
- [x] Snapshots MM-07, edição/legality MM-08 e replay MM-09 têm testes negativos de fronteira de confiança. A aceitação operacional do serviço continua pendente.
- [ ] PWA instala, atualiza e abre offline no navegador alvo.
- [ ] Android assinado instala e passa smoke em alvo suportado.
- [ ] Acessibilidade, touch, foco, contraste e revisão visual/original-brand têm aceite humano.

## Gates operacionais

- [x] Política de beta fechado, código MIT/DCO, conduta, segurança e conteúdo/proveniência estão versionadas.
- [ ] Responsáveis e rota privada de incidentes foram confirmados aos participantes do beta.
- [ ] Antes de abertura pública: Private Vulnerability Reporting e contato verificável de moderação/privacidade estão publicados.
- [ ] Evidência de deploy, configuração de retenção e rota de escalonamento foi registrada sem expor segredos.

## Blockers and reproduction actions

The following unchecked gates are intentional blockers, not inferred passes:

- **PWA install/update/touch acceptance — owner: az1nn.** Local evidence covers artifact validation and Chromium offline reload only. Reproduce the deterministic portion with `npm run build:pwa && npm run pwa:check`; then install the generated `web/` artifact in the supported browser, exercise update activation, and record a device/browser build and screenshot.
- **Android signed install/smoke — owner: az1nn.** This workspace lacks the Java runtime, Android SDK and `adb`. Reproduce when a target is available with `npm run android:debug`, install the generated APK, and record device/API level plus smoke evidence.
- **Human accessibility/visual/original-brand review — owner: az1nn plus human reviewer.** Headless Godot tests are not a substitute. Review touch targets, focus order, contrast, responsive layouts and original-brand content on supported targets; attach dated screenshots and reviewer identity.
- **Beta incident/privacy route and deploy operations — owner: az1nn.** Confirm the private route with participants, publish the vulnerability/moderation contacts, and record deployment/retention/escalation evidence without secrets.
- **Release tag/package evidence — owner: az1nn.** After the preceding gates pass, record the exact commit, tag, checksums, PWA/Android artifacts and smoke outputs. Keep the release explicitly closed-beta until then.

HYPOTHESIS: no additional external acceptance can be inferred from the local automated suites or from a successful artifact build.

## Evidência de release

- [ ] Tag, checksum/commit, artefatos PWA/Android e resultados de smoke são registrados.
- [x] Nenhuma carta Sandbox, submissão não aprovada ou edição suspensa aparece em deck/match competitivo; os negativos estão cobertos pelos gates MM-07/MM-08/MM-09.
- [ ] O release declara beta fechado enquanto os gates públicos permanecerem pendentes.
