# phoenix_nsmq

Flutter desktop application for the Phoenix NSMQ Quiz App.

## Getting Started

To run the application, you need to have Flutter installed on your machine. If you don't have Flutter installed, you can follow the instructions [here](https://flutter.dev/docs/get-started/install).

After installing Flutter, you can clone the repository and run the application using the following commands:

```bash
git clone
cd phoenix_nsmq
flutter run
```

You would need to specify a path to the questions file in the `lib/services.dart` file. The questions file should be in the following format:

```csv
question,answer,subject,reason
how are you,true,biology,
how are you,false,chemistry,because i am not fine
```
