# LOOP-001 — Pendências verificadas no origin (02/11/2026)

**Tipo:** backlog de remediação / complemento ao roadmap Spec Kit existente  
**Repositório:** https://github.com/az1nn/meme-mon  
**Baseline imutável da auditoria:** origin/master em 1f465f9c7654499b16cd3dc01ba43a2d882fd1c5  
**Fonte de verdade:** código, arquivos, PRs e checks no GitHub; relatórios locais são alegações até confronto com o origin.  
**Escopo:** documento de tarefas, sem implementação, sem acionamento do Pi, sem alteração do runner e sem merge.  
**Integração:** complementar a docs/tasks/LOOP-001-mememon-roadmap.md, sem substituir LOOP-P0-01..LOOP-P5-04 ou a fila existente do Pi.  
**Convenção:** - [ ] pendente; COMPLETE exige resultado no commit exato, comandos/evidências e gates próprios; WAITING_EXTERNAL não consome novas iterações sem nova evidência.

## Resumo das pendências

| ID | P | Tipo | Situação | Correspondência |
|---|---|---|---|---|
| LOOP-R01 | P0 | DOC | TODO | Todos os LOOP-P*; ledger e handoff |
| LOOP-R02 | P0 | AUDIT | TODO | LOOP-P5-03 / MM-09 |
| LOOP-R03 | P0 | CODE | TODO | LOOP-P5-03 / MM-09 |
| LOOP-R04 | P0 | CODE | TODO | LOOP-P5-03 / MM-09 |
| LOOP-R05 | P0 | CI | TODO | Exatidão dos gates do LOOP |
| LOOP-R06 | P0 | PROVIDER | WAITING_EXTERNAL | LOOP-P0-02 |
| LOOP-R07 | P0 | DELIVERY | BLOCKED_BY R06 | LOOP-P0-03 |
| LOOP-R08 | P1 | HUMAN | BLOCKED_BY R07 | LOOP-P0-04, P1-03 |
| LOOP-R09 | P1 | ART | WAITING_EXTERNAL | LOOP-P2-01 / PR #32 |
| LOOP-R10 | P1 | ART | WAITING_EXTERNAL | ARTIST-005 C06 / PR #33 |
| LOOP-R11 | P1 | SCENE | BLOCKED_BY R09/R10 | LOOP-P2-02/03 |
| LOOP-R12 | P1 | HUMAN | WAITING_HUMAN | LOOP-P3-02 |
| LOOP-R13 | P1 | HUMAN | BLOCKED_BY R07 | LOOP-P4-01 |
| LOOP-R14 | P2 | HUMAN | WAITING_HUMAN | LOOP-P4-02 / V1 Android |
| LOOP-R15 | P2 | GOVERNANCE | WAITING_EXTERNAL | LOOP-P5-01/02 |
| LOOP-R16 | P2 | PROVIDER | BLOCKED_BY R03/R04 | LOOP-P5-03 |
| LOOP-R17 | P2 | RELEASE | BLOCKED_BY prior gates | LOOP-P4-03, P5-04 |
| LOOP-R18 | P2 | OBSERVABILITY | TODO | Pi/Ralph reporting contract |

## P0 — Corrigir o que é executável sem novas aprovações

### LOOP-R01 — Reconciliar roadmap, relatório, claims e fila
- [ ] Comparar cada status do roadmap com o relatório consolidado e com arquivos, commits, PRs e CI efetivamente presentes no origin.
- [ ] Corrigir o cabeçalho desatualizado DOCUMENTED / NOT IMPORTED / NOT EXECUTED e estados divergentes sem presumir aceites humanos; conservar IDs originais.
- [ ] Reconciliar a fila já existente de Pi/Spec Kit e claims de concorrência, sem recriar estruturas ou sobrescrever sessões locais.
- **Aceite:** matriz LOOP-P* com status, prova exata, owner, blocker e ação; nenhum DONE baseado apenas em narrativa.
- **Evidência:** docs/reports/LOOP-001-session-history-2026-11-02.md vs. docs/tasks/LOOP-001-mememon-roadmap.md.

### LOOP-R02 — Confrontar relato MM-09 com o código em origin
- [ ] Registrar diff de escopo: relatório declara persistência automática e reidratação; origin/master não mostra o adaptador chamando OnlineMatchStore em start_match/intent nem importação de partidas no serviço.
- [ ] Marcar implementações locais não versionadas como NÃO ENTREGUES até encontrar o commit; preservar qualquer fonte recuperada e verificar autoria/compatibilidade antes de portar.
- **Aceite:** diagnóstico reproduzível apontando métodos presentes/ausentes e tests existentes, com SHA e conclusão explícita.
- **Evidência:** server/authoritative_websocket.gd; src/domain/authoritative_match_service.gd; src/data/online_match_store.gd; tests/run_mm09_tests.gd.

### LOOP-R03 — Persistência transacional dos eventos MM-09
- [ ] Implementar no adaptador a gravação de início de partida e intents aceitos; rejeitar/fazer rollback seguro quando persistência falhar conforme política fail-closed.
- [ ] Endurecer OnlineMatchStore: verificar sequência e integridade dos eventos, não apenas impedir diminuição do tamanho do array; documentar durabilidade e falhas de escrita.
- [ ] Testar autorização de participante, idempotência, gravação e falhas antes de considerar integração.
- **Aceite:** mudança de código e testes no mesmo SHA; nenhum evento confirmado ao cliente sem durabilidade exigida pelo contrato.
- **Depende:** R02. **Mapeia:** LOOP-P5-03.

### LOOP-R04 — Reidratação e replay MM-09 após reinício
- [ ] Criar importação validada dos registros com players, catálogos, decks, intents, idempotência e eventos.
- [ ] Reconstituir estado determinístico e rejeitar registros adulterados/incompletos; carregar partidas duráveis durante inicialização do servidor.
- [ ] Cobrir restart real, reconnect, replay, incompatibilidade de versão e falha segura no headless.
- **Aceite:** reinício recupera partidas válidas com replay equivalente e recusa registros corruptos, demonstrado por testes.
- **Depende:** R03. **Mapeia:** LOOP-P5-03.

### LOOP-R05 — Corrigir divergência entre relatório e comandos de teste
- [ ] Verificar a alegação de que CardVisualFrame entrou em npm test e que test:release cobre infraestrutura/PWA/Vercel; em origin/master isso não consta em package.json.
- [ ] Definir comandos adequados para npm test / test:release e adicionar cobertura sem duplicações nem executar publish.
- [ ] Fazer CI exact-head registrar MM-04/05/06/07-08/09, server, navegação, HUD, CardVisualFrame e checks de artefatos aplicáveis.
- **Aceite:** package.json e workflows coerentes; cada gate possui log e resultado identificáveis no commit exato.

## P0 — Preview Web, condicionado a provedor

### LOOP-R06 — Liberar pré-requisitos do preview Vercel
- [ ] Conferir ID de projeto, contexto de ambiente, existência dos secrets, permissões e autorização expressa para preview, sem expor valores.
- [ ] Confrontar job histórico Gate missing project setup com configuração vigente; não confundir job SKIPPED com entrega publicada.
- **Aceite:** prerequisites documentados e verificados pelo operador, com autorização de preview explícita.
- **Status:** WAITING_EXTERNAL; **owner:** operador GitHub/Vercel; **reabrir somente com:** credenciais/configuração e autorização novas.
- **Mapeia:** LOOP-P0-02.

### LOOP-R07 — Publicar e verificar preview do HEAD escolhido
- [ ] Despachar o workflow controlado de preview (não produção) somente após R06.
- [ ] Validar URL real e correspondência SHA/version.json, HTTP /, HTML, JS, PCK, WASM e MIME.
- **Aceite:** URL funcional e evidência de HEAD publicado; 404, SKIPPED ou build-only não são PASS.
- **Status:** BLOCKED_BY R06; **map:** LOOP-P0-03.

### LOOP-R08 — Homologar jornada offline no navegador real
- [ ] Testar desktop e touch: abrir preview, navegar, selecionar deck legal, duelo com bot, resultado, reload e persistência local.
- [ ] Documentar problemas com capturas e passos reproduzíveis, sem marcar aceitação pelo headless.
- **Aceite:** revisão humana PASS/ADJUST com navegador/versão, data e evidência.
- **Status:** BLOCKED_BY R07; **map:** LOOP-P0-04 e LOOP-P1-03.

## P1 — Arte e CardVisualFrame

### LOOP-R09 — Recuperar PNG aprovado C05 V3.2 e fontes C01/C05
- [ ] PR #32 mantém C01 SVG no branch e registra aprovação visual C05 V3.2, mas o PNG aprovado não foi commitado.
- [ ] Transferir o binário C05 V3.2 sem recompressão, verificar SHA-256 e dimensões declaradas no relatório do PR #32.
- [ ] Preservar C05 V3/V3.1 históricas e FIT A rejeitado; inventariar originais ainda ausentes sem afirmar equivalência binária.
- **Aceite:** blob PNG navegável no PR, hash confirmado, proveniência e revisão ART; não fazer merge automático.
- **Status:** WAITING_EXTERNAL (transporte do binário); **owner:** ART/operador; **reabrir com:** bytes acessíveis e verificáveis.

### LOOP-R10 — Importar C06 V1.1 aprovada
- [ ] PR #33 documenta aprovação visual C06 V1.1, mas seu SVG V1 foi rejeitado como corrompido e não representa o binário aprovado.
- [ ] Importar PNG exato V1.1 com hash, tamanho, dimensões e proveniência, mantendo propostas rejeitadas separadas.
- [ ] Executar gate ART e preparar validações ARCH/SCENE/INSPECTOR, sem integração ou merge automático.
- **Aceite:** binário presente no PR #33 e gate de fonte comprovado; aprovação visual não é aceite técnico.
- **Status:** WAITING_EXTERNAL; **owner:** ART/operador; **reabrir com:** PNG transferido.

### LOOP-R11 — Integrar arte aprovada ao CardVisualFrame
- [ ] Após R09/R10, validar alpha técnico, safe area, proporção, frente/verso, flip, touch e downsampling no Godot.
- [ ] Executar testes de componente e capturas reais Web/mobile, sem substituir baseline nem alterar regras de jogo.
- **Aceite:** testes exact-head e decisão ART/SCENE/ARCH/INSPECTOR documentada.
- **Status:** BLOCKED_BY R09/R10; **map:** LOOP-P2-02/03.

## P1/P2 — Aceites de Forge, PWA e Android

### LOOP-R12 — Aceite visual e touch do Forge
- [ ] Realizar fluxo create → preview privado → save → reopen em desktop e mobile; confirmar isolamento Sandbox/Canon.
- **Aceite:** captura, resultados e decisão humana assinada; testes automatizados MM-06 são evidência parcial.
- **Status:** WAITING_HUMAN; **map:** LOOP-P3-02.

### LOOP-R13 — Aceite PWA de instalação e atualização offline
- [ ] Verificar instalação, primeira abertura, restart sem rede, cache, troca de versão, rollback e recuperação em navegador real.
- **Aceite:** logs/capturas por plataforma e SHA do artefato publicado.
- **Status:** BLOCKED_BY R07 para preview remoto; **map:** LOOP-P4-01.

### LOOP-R14 — Android e revisão de acessibilidade/identidade
- [ ] Build assinado Android e teste de instalação em dispositivo/emulador suportado, se dentro do release V1 autorizado.
- [ ] Verificar foco, contraste, controles touch, responsividade e identidade original; não tratar build Web como aprovação Android.
- **Aceite:** build identificável, matriz de dispositivos e revisão humana PASS/ADJUST.
- **Status:** WAITING_HUMAN / ambiente; **map:** LOOP-P4-02 e docs/tasks/V1-release-tasks.md.

## P2 — Operação e lançamento V1

### LOOP-R15 — Fechar MM-07/MM-08 com operadores
- [ ] Obter walkthrough de moderação, contatos de privacidade, retenção e provas de direitos/proveniência para MM-07.
- [ ] Obter decisões de assinatura, rotação, conteúdo elegível e publicação Canon para MM-08.
- **Aceite:** responsáveis, evidências datadas e gates sem ambiguidades; testes locais não concedem autorização pública.
- **Status:** WAITING_EXTERNAL; **map:** LOOP-P5-01/02.

### LOOP-R16 — Homologar autoridade MM-09 hospedada
- [ ] Após R03/R04, selecionar endpoint hospedado aprovado, validar identidade, TLS/rede, reconnect/replay, persistência, retenção e carga.
- [ ] Separar sucesso do transporte local de prontidão operacional do serviço online.
- **Aceite:** evidência end-to-end hospedada, contrato e revisão de segurança/operação.
- **Status:** BLOCKED_BY R03/R04 e provedor; **map:** LOOP-P5-03.

### LOOP-R17 — Consolidar checkpoint offline e release V1
- [ ] Reconciliar todas as provas P0–P5, incidentes, arte, Android, acessibilidade, licenças, segurança e governança com a constituição.
- [ ] Apresentar GO/NO-GO; nenhuma tag, deploy produção, merge ou promoção UGC sem autorização explícita.
- **Aceite:** checklist com SHA, links, assinaturas/gates e decisão humana.
- **Status:** BLOCKED_BY gates anteriores; **map:** LOOP-P4-03 e LOOP-P5-04.

### LOOP-R18 — Evidência auditável das rodadas Pi/Ralph
- [ ] Conservar no pacote local .ralph/tasks um WORK_REPORT.md único, RALPH_PROGRESS.md curto e OPEN_QUESTIONS.md só com gates externos, conforme PI-LOOP.md.
- [ ] Consolidar resultados relevantes no GitHub sem versionar logs secretos nem afirmar acesso remoto aos logs da máquina.
- [ ] Anotar iteração, tarefa, commit, comandos PASS/FAIL, tempo/tokens/custo apenas quando medidos e próximo passo único.
- **Aceite:** handoff legível com métricas observadas ou N/D, sem relatórios repetidos para blockers sem mudança.
- **Status:** TODO; execução local pelo operador/runner Pi existente.

## Sequência de ataque recomendada

1. **Agora / sem provedor:** R01 → R02 → R03 → R04 → R05. Cada item deve ser uma iteração bounded, com testes no código modificado.
2. **Em paralelo / externos:** R06 (Vercel) e R09/R10 (assets). Se permanecerem bloqueados, registrar owner e condição de reabertura uma vez; não repetir polls.
3. **Após desbloqueio:** R07 → R08 → R13; R09/R10 → R11; R12 e R14 conforme disponibilidade humana.
4. **V1 online:** R15/R16 → R17, com gates constitucionais e aprovação explícita.

## Evidências base (URLs estáveis)

- HEAD: https://github.com/az1nn/meme-mon/commit/1f465f9c7654499b16cd3dc01ba43a2d882fd1c5
- LOOP-001: https://github.com/az1nn/meme-mon/blob/master/docs/reports/LOOP-001-session-history-2026-11-02.md
- Roadmap: https://github.com/az1nn/meme-mon/blob/master/docs/tasks/LOOP-001-mememon-roadmap.md
- Servidor: https://github.com/az1nn/meme-mon/blob/master/server/authoritative_websocket.gd
- Serviço: https://github.com/az1nn/meme-mon/blob/master/src/domain/authoritative_match_service.gd
- Store: https://github.com/az1nn/meme-mon/blob/master/src/data/online_match_store.gd
- Scripts: https://github.com/az1nn/meme-mon/blob/master/package.json
- PR arte C01/C05: https://github.com/az1nn/meme-mon/pull/32
- PR arte C06: https://github.com/az1nn/meme-mon/pull/33
- CI HEAD: https://github.com/az1nn/meme-mon/actions/runs/41470314454

## Guardrails

- REAL STATE do origin > execução comprovada > relatório consolidado > memória de chat.
- Não declarar tarefa DONE por status de workflow verde parcial, PR draft, auditoria ou aprovação visual isolada.
- Respeitar gates humanos e políticas de publicação; o loop não executa push/merge/deploy sem autorização individual correspondente.
- Preservar todo código útil, testes, IDs Spec Kit, branches e PRs preexistentes. Sem duplicar runner Pi nem a skill loop já integrada.
