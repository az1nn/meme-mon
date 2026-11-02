# Pi agent loop

Este repositório usa o loop nativo do **Pi** por meio da extensão
`@lnilluv/pi-ralph-loop`. Este documento substitui o antigo `RALPH.md`, que
usava um executor separado baseado em OpenCode e `ralph.sh`.

## Princípios

- O agente roda em iterações independentes; o progresso deve ficar nos arquivos,
  testes, commits e `RALPH_PROGRESS.md`, não apenas no contexto da conversa.
- Cada iteração executa uma tarefa bounded e verificável.
- Implementação vem antes de revisão e aceitação externa.
- Erros não críticos podem virar follow-up e não bloqueiam PRs independentes.
- Gates humanos, de dispositivo, provider, licensing, moderation e operations
  nunca podem ser inferidos como aprovados por testes headless.
- O loop não faz `push`, merge ou publicação automaticamente sem autorização
  explícita do usuário.

## Instalação e carregamento

A extensão deve estar instalada no ambiente do Pi:

```text
pi install npm:@lnilluv/pi-ralph-loop
```

Depois de instalar, recarregue o Pi com `/reload` ou reinicie a sessão.
Verifique a instalação com:

```text
pi list
```

`/ralph` é um comando slash nativo do Pi. Não execute `/ralph` dentro do Bash.

## Estrutura de um loop

Cada loop deve ter uma pasta própria, normalmente em `.ralph/tasks/`:

```text
.ralph/tasks/<nome-do-loop>/
├── RALPH.md       # configuração YAML + prompt do agente
├── TASKS.md       # roadmap ordenado e critérios de conclusão
├── RALPH_PROGRESS.md  # memória entre iterações, quando usada
└── OPEN_QUESTIONS.md  # perguntas/bloqueios, quando aplicável
```

`RALPH.md` usa frontmatter YAML com chaves `snake_case`. Exemplo mínimo:

```yaml
---
max_iterations: 16
timeout: 300
completion_promise: DONE
completion_gate: required
stop_on_error: false
required_outputs:
  - RALPH_PROGRESS.md
guardrails:
  block_commands:
    - 'git\\s+push'
    - 'git\\s+merge'
  protected_files:
    - '.env*'
    - '*.pem'
    - 'policy:secret-bearing-paths'
---
# Execute tasks

Você é um agente de código autônomo rodando em um loop Pi. Leia `TASKS.md`,
execute uma tarefa bounded por iteração, valide o resultado e atualize a
memória de progresso.
```

## Criar e executar

Para transformar uma solicitação em um pacote de loop:

```text
/ralph-draft "implementar e validar os gaps restantes do V1"
```

Para executar uma pasta já criada:

```text
/ralph --path ./.ralph/tasks/<nome-do-loop>
```

Também é possível criar um esqueleto:

```text
/ralph-scaffold --preset fix-tests ./.ralph/tasks/<nome-do-loop>
```

O loop nunca deve ser infinito. Use `max_iterations` como limite de segurança
e defina uma `completion_promise` somente quando houver critérios objetivos de
conclusão.

## Comandos de operação

```text
/ralph-list
/ralph-status ./.ralph/tasks/<nome-do-loop> --summary
/ralph-resume ./.ralph/tasks/<nome-do-loop>
/ralph-stop ./.ralph/tasks/<nome-do-loop>
/ralph-cancel ./.ralph/tasks/<nome-do-loop>
/ralph-logs ./.ralph/tasks/<nome-do-loop>
```

Use `/ralph-stop` para terminar após a iteração atual. Use `/ralph-cancel`
apenas quando for necessário interromper imediatamente.

## Roadmap atual

A fila de execução deve ser mantida no `TASKS.md` do pacote ativo. O roadmap
atual é:

1. **CODE-CARDVISUALFRAME** — implementar gaps restantes de código/integração e
   testes de regressão do CardVisualFrame.
2. **CODE-MM09-TRANSPORT** — implementar um gap bounded de authority, transporte,
   reconnect ou replay do MM-09.
3. **CODE-DELIVERY-ACCEPTANCE** — implementar validações automatizáveis de PWA,
   Android e artefatos.
4. **CODE-TRUST-GOVERNANCE** — fechar um gap concreto de trust boundary em
   MM-07/MM-08/MM-10.
5. **CODE-FOLLOWUP-FINDINGS** — transformar achados adiados em tarefas de código
   bounded.
6. **PR-027 / PR-028** — concluir as correções dentro do escopo dos PRs.
7. **PR-027-REVIEW / SIGA-REVIEW** — revisar evidência, ownership e limites dos
   pacotes.
8. **V1-EXTERNAL-ACCEPTANCE** — preparar evidência de browser, PWA, Android,
   acessibilidade e operação.
9. **MM06-HUMAN-REVIEW** — aceitar Forge visual/touch e a fronteira Sandbox.
10. **MM07-MM10-OPERATIONS** — concluir revisão operacional e de políticas.
11. **V1-RELEASE-CLOSE** — montar evidência final e fechar somente com todos os
    gates obrigatórios comprovados.

## Regras de implementação

Cada iteração deve:

1. Ler o estado real do repositório, branch, PR e CI.
2. Escolher a primeira tarefa pendente do `TASKS.md`.
3. Fazer uma mudança bounded, sem criar uma segunda arquitetura.
4. Adicionar ou atualizar testes quando houver alteração de código.
5. Executar os comandos de validação da tarefa.
6. Atualizar `RALPH_PROGRESS.md` com mudanças, evidência, bloqueios e próximo
   passo.
7. Emitir a promise de conclusão somente quando os outputs e gates exigidos
   estiverem prontos.

Não marcar uma tarefa como concluída apenas porque arquivos foram criados.
Falhas de ambiente ou gates externos devem ser registradas com responsável e
próxima ação. Achados não críticos podem ser adiados, mas não podem ser
silenciosamente apagados ou convertidos em aprovação.

## Referências

- `.specify/memory/constitution.md`
- `docs/ROADMAP.md`
- `.ralph/tasks/`
- Skill local `ralph-loop`
- Documentação do Pi em `/home/az1nn/.pi/agent/install/releases/1.4.0/node_modules/@earendil-works/pi-coding-agent/docs`
