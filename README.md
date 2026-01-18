# TicTacToeCodex (Godot 4.x)

Polished Tic-Tac-Toe with Player vs Engine mode, selectable difficulty, and Android AdMob monetization (banner + rewarded) using the Poing Studios AdMob plugin.

## Setup Summary
- Open the project in Godot 4.x.
- Install the Poing Studios AdMob plugin into `addons/godot-admob`.
- Enable the plugin in **Project Settings → Plugins**.
- Update `config/ads_config.gd` with your AdMob App ID and ad unit IDs.

## Android Notes
- Ads are disabled on Desktop via a NullAdsService implementation.
- Banner ads show on Main Menu and Game Over.
- Rewarded ad grants a single undo after Game Over (one per match).
