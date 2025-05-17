{ inputs, system }:
[
  (final: prev: {
    ags-agenda = inputs.ags-agenda.packages."${system}".default;
  })
]
