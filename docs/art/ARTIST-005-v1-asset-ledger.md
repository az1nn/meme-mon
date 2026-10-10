# ARTIST-005 — Inventário de assets V1 e ledger de aprovações

**Repositório:** az1nn/meme-mon  
**Data do gate T01:** 2026-10-10 (Brasil)  
**Estado:** INVENTORY ACTIVE; T01 CONCEPT_APPROVED; T02 NEXT  
**Total:** 74 itens/famílias planejadas, **não** 74 imagens independentes nem 74 features autorizadas. Reusar componentes por padrão.

## Autoridade e fronteiras

- Estilo: ARTIST-003 cartoon-first tropical rooftop e ARTIST-004 screen-board aprovados. Preview do T01 tem novo aceite humano específico; as duas referências anteriores continuam valendo.
- **T01 é aprovado como composição/arte de tela (CONCEPT_APPROVED)**, não como licença de personagens, mascotes, logo final, regras, implementação Godot ou asset separado.
- V1: Godot Web local/in-memory, duelo determinístico; **G1 D card-first, G2 D, G3 C, G4 A, G5 C, G6 D, G7 B, G8 A, G9 D, G10 D provisório**. Sem login, multiplayer, monetização, catálogo público ou serviço remoto obrigatório.
- Os elementos ilustrativos do concept (nomes, nível, estrelas, botões `Item`/`Fugir`, posses, placares e valores arbitrários) **não alteram** Alpha 0.1. Implementação deve derivar ações/atributos válidos de `MatchState`/`PlayerIntent` e usar os cinco tipos canônicos **Classic, Reaction, Brainrot, Surreal, Wholesome**. `Mememom`, `Reaction` e `Format` são classes de carta, não raridades.
- A ordem P0/P1/P2 aqui é de **produção visual**, não reordena as dependências MM-06 → MM-07 → MM-08 no roadmap de produto.

## Gate específico T01 — aprovado

- **Arte fonte:** `duelo_tropical_de_cartas_no_rio.png`; preview 941 × 1672 px, RGB PNG.
- **SHA-256:** `79d2e9717022820aea46ae2cf052f11a880e90bf0e132293a65275aeebaa51c2` (calculado sobre os bytes locais do PNG gerado).
- **Decisão humana:** `APROVADO` explicitamente após exibição do T01.
- **Escopo aceito:** tela vertical de duelo, atmosfera cartoon urbana/tropical, duas cartas Active com ilustrações, composição de mão, ações contextuais, topo com hambúrguer e indicação do turno.
- **Pendências objetivas:** sem aprovação individual de P01/P06, sem marca final, sem confirmação de mecânicas sugeridas por labels ilustrativas, sem teste de toque/responsividade, sem screenshot real do Godot; validação ART/SCENE/ARCH/INSPECTOR ainda separada.
- **Importação binária no GitHub:** PENDING — não tratar SHA registrado como prova de arquivo anexado. Caminho sugerido quando for importado: `docs/art/references/ARTIST-005-T01-mobile-duel-approved.png`. Antes de marcar importação completa, verificar SHA exato da referência.

## Fila completa (um por vez)

### T — Telas V1

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| T01 | Duelo mobile card-first | P0 | CONCEPT_APPROVED |
| T02 | Menu hambúrguer aberto (mobile) | P0 | NEXT |
| T03 | Duelo desktop/web responsivo | P1 | PENDING |
| T04 | Coleção | P1 | PENDING |
| T05 | Deckbuilder | P1 | PENDING |
| T06 | Detalhes da carta | P1 | PENDING |
| T07 | Meme Forge privado | P2 | PENDING_MM06 |
| T08 | Configurações e acessibilidade | P2 | PENDING |
| T09 | Resultado da partida | P2 | PENDING |
| T10 | Estados vazios/erros/armazenamento local | P2 | PENDING |

### C — Cartas

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| C01 | Moldura base comum | P0 | PENDING |
| C02 | Moldura rara | P1 | PENDING |
| C03 | Moldura épica | P1 | PENDING |
| C04 | Moldura lendária | P1 | PENDING |
| C05 | Verso de carta original | P0 | PENDING |
| C06 | Template Active (duelo) | P0 | PENDING |
| C07 | Template Hand (duelo) | P0 | PENDING |
| C08 | Template miniatura de coleção | P1 | PENDING |
| C09 | Badge de custo Trend | P0 | PENDING |
| C10 | Badge HP/estatísticas | P0 | PENDING |
| C11 | Badge tipo canônico | P1 | PENDING |
| C12 | Área de habilidade | P1 | PENDING |

### P — Ilustrações originais (nomes ilustrativos; não Canon)

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| P01 | Caramelo | P0 | PENDING_CHARACTER_REVIEW |
| P02 | Sapo Zinho | P0 | PENDING_CHARACTER_REVIEW |
| P03 | Gato de Rua | P0 | PENDING_CHARACTER_REVIEW |
| P04 | PombaTech | P1 | PENDING_CHARACTER_REVIEW |
| P05 | Axolote | P1 | PENDING_CHARACTER_REVIEW |
| P06 | Capivaro | P1 | PENDING_CHARACTER_REVIEW |

### U — Componentes UI/HUD

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| U01 | Botão primário contextual | P0 | PENDING |
| U02 | Botão secundário contextual | P0 | PENDING |
| U03 | Botão perigoso/destrutivo | P2 | PENDING |
| U04 | Header comum responsivo | P0 | PENDING |
| U05 | Gatilho hambúrguer | P0 | PENDING |
| U06 | Drawer sobreposto/fechamento | P0 | PENDING |
| U07 | Grupo de ações de duelo | P0 | PENDING |
| U08 | Container de mão local | P0 | PENDING |
| U09 | Indicador Hype (0–5) | P0 | PENDING |
| U10 | Indicador Trend/cap | P0 | PENDING |
| U11 | HP apenas em Mememom | P0 | PENDING |
| U12 | Filtros/tabs da coleção | P1 | PENDING |
| U13 | Campo busca coleção | P1 | PENDING |
| U14 | Modal/popup base | P2 | PENDING |
| U15 | Painel genérico de resultado (sem recompensas não previstas) | P2 | PENDING |

### I — Ícones e indicadores

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| I01 | Hambúrguer | P0 | PENDING |
| I02 | Coleção | P1 | PENDING |
| I03 | Deck | P1 | PENDING |
| I04 | Duelo | P1 | PENDING |
| I05 | Configurações | P1 | PENDING |
| I06 | Voltar | P1 | PENDING |
| I07 | Fechar | P1 | PENDING |
| I08 | Hype | P0 | PENDING |
| I09 | Trend | P0 | PENDING |
| I10 | HP | P0 | PENDING |
| I11 | Ataque | P1 | PENDING |
| I12 | Habilidade/efeito | P1 | PENDING |
| I13 | Ação contextual derivada do MatchState (não inventar item) | P2 | PENDING |
| I14 | Aviso offline/storage | P2 | PENDING |
| I15 | Placeholder/estado vazio | P2 | PENDING |

### B — Fundos reutilizáveis

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| B01 | Arena de duelo — terraço tropical cartoon | P0 | PENDING |
| B02 | Fundo para entry/home (opcional) | P1 | PENDING |
| B03 | Fundo coleção genérico reaproveitável | P1 | PENDING |
| B04 | Fundo deckbuilder (preferir B03 reaproveitado) | P1 | PENDING |
| B05 | Fundo resultado (preferir variação B01) | P2 | PENDING |
| B06 | Fundo estados/erros (preferir componentes genéricos) | P2 | PENDING |

### V — VFX de apresentação Godot

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| V01 | Ataque | P1 | PENDING |
| V02 | Habilidade | P1 | PENDING |
| V03 | Hit/dano | P1 | PENDING |
| V04 | KO | P2 | PENDING |
| V05 | Seleção/foco | P1 | PENDING |
| V06 | Active-card destaque | P1 | PENDING |

### M — Marca/apoio provisório

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| M01 | Wordmark original MEMEMOM | P2 | BRAND_GATE_OPEN |
| M02 | Símbolo/insígnia original | P2 | BRAND_GATE_OPEN |
| M03 | Banner interno (não requisito V1) | P3 | DEFERRED |
| M04 | Avatar genérico do player (não personagem final) | P2 | PENDING |

## Fluxo de produção e validação

1. **RECONCILE:** conferir asset ID, referência aprovada, branch/PR ativo, ownership e conflitos.
2. **GENERATE:** produzir exatamente **um preview por asset solicitado** e apenas as variantes necessárias, com arte no mesmo padrão V1 (não galeria multi-tela).
3. **HUMAN GATE:** aprovação explícita `APPROVED`, `ADJUST`, `REJECT`. Um aceite de tela não aprova automaticamente seus fragmentos e personagens.
4. **FREEZE CONCEPT:** guardar ID, versão, PNG original, dimensões, SHA256, escopo da aprovação, limitações e path/referência (não substituir silenciosamente versões aceitas).
5. **IMPLEMENT / VERIFY:** somente com escopo autorizado. SCENE integra Godot, ARCH verifica contratos, INSPECTOR compara evidências do runtime exato com o conceito; SIGA controla concorrência, testes, CI e handoff.
6. **REPORT:** sempre explicitar `CONCEPT_APPROVED` versus `RUNTIME_VERIFIED` e imagens binárias `IMPORTED` versus `PENDING`.

## Próxima unidade

**T02 — Menu hambúrguer aberto (mobile):** desenhar overlay acessível sobre a T01 preservada, com apenas as rotas realmente implementadas (Duelo, Coleção). Outras rotas devem ser ausentes ou claramente indisponíveis até que tenham escopo e implementação. Fechar por X, toque externo e back/Escape; sem barra inferior ou sidebar fixa.

**Fase seguinte (sem geração automática):** após human gate T02, avançar T03 e prosseguir pela fila; na produção individual de ilustrações, começar pela base reutilizável B01/C01 antes de variações de personagens, respeitando o pedido explícito do usuário.
