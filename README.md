### Coin Flip (Flutter):
A game inspired by Stake made in Flutter.

### Demo Video:
https://github.com/user-attachments/assets/de27c4fd-f897-45ad-994c-ed740cfa1138

### Project Setup:
1. Fork the repository.
2. Clone it and open it on your local machine.
3. `cd` into `flip_flutter` and run `flutter run -v`.
4. You will be prompted in the terminal to choose the machine. Press `2` to start a Chrome instance.
5. Your local development server will be ready.

### Code Structure:
1. The entry point of the file is `lib/main.dart`. It contains all the states that are required in other widgets as well.
2. `main.dart` consists of 3 child widgets - Header, Sidebar, and GameContainer.
3. These child widgets can be found inside the `lib/components` folder.
4. The header contains the header as the name says and shows the wallet balance.
5. The sidebar consists of most of the things, all the major UI and game logic required to play the game is inside sidebar widget.
6. The GameContainer widget consists of the main game container where the coin and its animation are shown, along with the bet history.
