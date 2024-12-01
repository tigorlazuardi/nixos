{ inputs, system }:
[
  (final: prev: {
    zen-browser = inputs.zen-browser.packages."${system}".default;
    ags-agenda = inputs.ags-agenda.packages."${system}".default;
  })
]
