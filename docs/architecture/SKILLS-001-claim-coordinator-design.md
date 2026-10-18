# SKILLS-001 — Inventário verificável e escolha do coordenador de claims

Status: DESIGN_RECONCILED / RUNTIME_NOT_IMPLEMENTED
Verificação: 2026-10-18 (GitHub, PR #15 head `6a0b31fa90ad528045e97f8ad2140d8a2c28cc7b`)
Escopo: exclusivamente `az1nn/meme-mon`; não modifica SIGA canônico, arte, Godot ou PR #13.

## Inventário encontrado

| Local | Evidência | Consequência |
|---|---|---|
| `meme-mon` PR #15, árvore Git completa não truncada | `.github/workflows/godot-ci.yml`, `web-delivery.yml`, `.specify/memory/constitution.md`, `docs/SIGA-HANDOFF.md`, `docs/architecture/SKILLS-001-operating-model.md`; nenhum diretório de executores `.agents/skills`, `.github/skills` ou claim store neste HEAD | Há contratos/documentos de skills, mas **não** há coordenador distribuído integrado ao runtime do repositório |
| `az1nn/cpxlabs-admin` master | `.agents/skills/siga/SKILL.md` acessível, protocolo VERIFY-FIRST com fencing obrigatório | Fonte procedimental SIGA adotada por SKILLS-001; **não** duplicar código ou redefinir esta skill |
| `az1nn/az1nn` main | `.github/skills/siga/SKILL.md`, `.github/skills/godot/SKILL.md`, `.github/skills/README.md`, `AGENTS.md` | Catálogo global também se autoidentifica como canônico *no próprio repositório*. Potencial divergência inter-repositório; compatibilizar por ponteiros e escopo, jamais apagar sem governança própria |
| GitHub Actions do MemeMon | headless `mm04` + web-delivery; verificações Godot, não mutex de editores | CI verde não demonstra exclusão mútua de agentes |
| PR #13 e issue #9 | ARTIST-003/005 draft e gate visual em aberto | Não atravessar ownership artístico nem inferir autorização para C05/C06/merge |

**Limites do inventário:** a árvore Git não enumera extensões/skills locais em máquinas de agentes, instalações privadas, webhooks externos, outros repositórios, processos ativos ou caches não indexados. Essa varredura **não** permite fechar o checklist "todos os consumidores" sem instrumentação/evidência de cada ambiente.

## Decisão técnica: GitHub GraphQL `updateRefs` como primitiva CAS

A API REST `PATCH /git/refs` oferece `sha` e `force`; `force=false` restringe non-fast-forward, mas não representa a condição atômica `old == expected`. Uma sequência `GET -> REST PATCH` pode perder a corrida. Comentários, labels, arquivos com apenas blob SHA, branches listadas, Actions concurrency groups e leases locais também **não** são prova de mutex distribuído.

A mutação GraphQL `updateRefs` suporta `RefUpdate.beforeOid` e `afterOid`; o servidor rejeita o lote inteiro se qualquer precondição divergir. Desenho escolhido para implementação/teste:

1. Um ref exclusivo, `refs/heads/siga-claims-v1`, mantém uma versão imutável de `.siga/claims.json`; criação inicial com `beforeOid = 0000000000000000000000000000000000000000`.
2. Chave de claim: `repo + workstream + task`. Registro: `owner`, `run_id`, `lease_id` aleatório, `fence_generation`, `branch`, `head_sha`, `state`, `expires_at`. Nunca reutilizar `lease_id`.
3. Acquire, renew, release e recovery geram novo commit para o estado do claim e trocam o ref **somente** com `beforeOid` exato. Em conflito, rejeitar e classificar WATCH; não fazer retry de mutação às cegas.
4. Atualização da branch de trabalho deve usar **o mesmo lote GraphQL atômico** para atualizar claim-ref e feature-ref, com os dois `beforeOid` exatos, novo `head_sha` e token/fence corrente. Uma checagem separada seguida de write desprotegido ainda seria vulnerável a TOCTOU.
5. Expiração não libera claim automaticamente. Recovery exige reconciliação remota de branch, PR, CI, ausência de owner ativo e evidência explícita; incremento de fencing. Release somente com token atual; owner antigo não pode apagar claim novo.
6. Segredos/tokens nunca entram no ledger; permissões mínimas; ref de coordenação não deve entrar na pipeline de publicação do Godot. Falha de auth/API/GraphQL/consistência implica fail-closed/WATCH.

Referências oficiais: https://docs.github.com/en/graphql/reference/git#updaterefs e https://docs.github.com/en/rest/git/refs#update-a-reference

## Gates de implementação ainda ABERTOS

- [ ] Entregar cliente CLI GitHub GraphQL `updateRefs` e armazenamento versionado, **sem** fallback REST não atômico.
- [ ] Testar dois acquires simultâneos no mesmo `beforeOid`: exatamente um PASS e outro WATCH.
- [ ] Testar renew, release do owner antigo, expiração sem takeover, recovery documentado e fencing da ref de trabalho.
- [ ] Integrar os mutadores reais à operação fenced; detectar e negar writes por caminhos sem token. Um cliente isolado, sem adoção por todos os writers, **não** corrige a race condition.
- [ ] Validar tokens/permissões, corrida real entre dois clientes independentes, CI no HEAD exato e gates humanos/PRs.
- [ ] Não realizar merge até cumprimento integral; o Godot headless PASS de 2026-10-15 valida somente o baseline documental atual.

## Handoff da unidade

Classificação: **RESUME — SKILLS-001**. O inventário indexado e a decisão CAS são evidência documental, não uma implantação. Próxima unidade técnica: CLI + testes de contenção/fencing + integração fail-closed. O workstream ARTIST continua WATCH, intocado.
