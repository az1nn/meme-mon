---
max_iterations: 10
timeout: 300
completion_gate: disabled
stop_on_error: false
guardrails:
  block_commands:
    - 'git\s+push'
    - 'git\s+merge'
    - 'git\s+reset\s+--hard'
    - 'rm\s+-rf\s+/'
  protected_files:
    - '.env*'
    - '*.pem'
    - 'policy:secret-bearing-paths'
---
# Ralph Loop para Mememom

O projeto usa o [Ralph Loop](https://ralphloop.sh/blog/ralph-loop-with-opencode/)
com OpenCode para executar tarefas planejadas em iterações curtas e limitadas.
Cada iteração recebe um contexto novo, executa uma única tarefa, valida o
resultado e cria um commit.

## Pré-requisitos

- WSL2 Ubuntu com Node.js 22+, npm, Git e Godot 4.7.2.
- `opencode` autenticado no ambiente em que o loop será executado.
- Worktree limpo e uma branch diferente de `master`.

O loop já está versionado em `ralph.sh` e usa o núcleo oficial do Ralph v2.7.0.

## Execução Local

O modo padrão executa o OpenCode diretamente no WSL:

```bash
cd /home/az1nn/meme-mon
git switch -c ralph/v1-work
./ralph.sh --agent opencode --once
```

Para continuar com um limite explícito:

```bash
./ralph.sh --agent opencode --max-iterations 8
```

O loop nunca deve ser infinito. `--max-iterations` é um limite de segurança,
não uma meta obrigatória.

## Docker Sandbox

O modo direto é o padrão no WSL. Para usar Docker Sandboxes, instale e
autentique o `sbx`, então execute:

```bash
RALPH_DIRECT_MODE=0 ./ralph.sh --login --agent opencode
RALPH_DIRECT_MODE=0 ./ralph.sh --agent opencode --max-iterations 8
```

No modo direto, `--login` e `--ports` apenas informam que as operações de
Sandbox não são necessárias.

## Fila de Tarefas

A fila principal está em `.agent/tasks.json`. Cada tarefa possui uma
especificação detalhada em `.agent/tasks/` e deve apontar para a especificação
ou plano correspondente em `docs/`.

Fila atual do Ralph, em ordem:

- `PR-027-REVIEW`: revisar e finalizar CardVisualFrame / ART-002.
- `SIGA-REVIEW`: revisar o pacote Spec Kit do SIGA-CENTRAL-001.
- `V1-EXTERNAL-ACCEPTANCE`: preparar e executar os gates externos restantes da V1.
- `MM06-HUMAN-REVIEW`: concluir a revisão visual/touch do Forge.
- `MM07-MM10-OPERATIONS`: revisar aceitação operacional e de políticas de MM-07 a MM-10.
- `V1-RELEASE-CLOSE`: montar a evidência final e fechar a release somente com todos os gates.

As tarefas históricas concluídas (`V1-001`, `PR-026` e `V1-002`) permanecem registradas no `.agent/tasks.json`. Achados não críticos podem ser registrados para uma tarefa posterior e não bloqueiam a revisão do trabalho atual ou PRs independentes; gates humanos, de dispositivo, operação e release continuam explicitamente pendentes até haver evidência.

O agente deve completar somente uma tarefa por iteração. Ele deve emitir um
destes sinais no final:

```text
<promise>TASK-{ID}:DONE</promise>
<promise>COMPLETE</promise>
<promise>BLOCKED:motivo</promise>
<promise>DECIDE:pergunta</promise>
```

## Steering Durante a Execução

Edite `.agent/STEERING.md` para orientar a próxima iteração sem interromper o
processo. O agente lê esse arquivo antes de selecionar a tarefa normal.

Logs ficam em:

- `.agent/logs/LOG.md`: progresso resumido.
- `.agent/history/`: saída completa por iteração.
- `.agent/screenshots/`: evidência visual quando aplicável.

Esses artefatos de execução são ignorados pelo Git, exceto pelos arquivos
`.gitkeep` estruturais.

## Limites de Segurança

O Ralph recusa execução em `master` por padrão:

```bash
git switch -c ralph/minha-tarefa
```

Não use `RALPH_ALLOW_MASTER=1` em execução AFK normal. O agente não deve:

- usar `git reset --hard`;
- fazer force-push;
- apagar branches ou issues;
- publicar em produção;
- fechar issues automaticamente;
- marcar aprovação humana, visual, de dispositivo, licença ou operação como concluída apenas por CI.

Falhas repetidas, credenciais ausentes, serviços indisponíveis ou gates
externos devem terminar com `BLOCKED`, não com tentativas infinitas.

## Merge de Pull Requests

O proprietário autorizou merge de PRs em draft. O status draft não bloqueia o
merge, mas os gates técnicos continuam obrigatórios.

O helper Git-only valida o HEAD do PR em um worktree temporário, executa
`git diff --check` e `npm test`, e só então integra em `master`:

```bash
RALPH_ALLOW_DRAFT_MERGE=1 \
  tools/ralph-merge.sh <numero-do-pr> --allow-draft
```

Requisitos mantidos:

- HEAD do PR baseado no `origin/master` atual;
- worktree `master` limpo;
- testes locais do HEAD passando;
- merge sem force-push;
- push normal para `origin/master`.

O helper usa apenas Git e não consulta metadados de revisão do GitHub. A
autorização explícita do proprietário substitui a exigência de aprovação para
este ambiente AFK, mas não substitui testes, resolução de conflitos ou gates
externos.

## Validação Manual

Antes de iniciar uma sessão longa:

```bash
bash -n ralph.sh scripts/lib/*.sh tools/ralph-merge.sh
git diff --check
npm test
```

O comando `npm test` cobre os gates Godot MM-04 a MM-09, servidor WebSocket,
navegação e HUD. Os gates de navegador real, Android físico/emulado,
acessibilidade, licenciamento, operação e publicação continuam exigindo
evidência externa.

## Referências

- `docs/plans/AFK-development-loop.md`
- `.agent/PROMPT.md`
- `.agent/tasks.json`
- `.specify/memory/constitution.md`
- [Ralph Loop com OpenCode](https://ralphloop.sh/blog/ralph-loop-with-opencode/)
