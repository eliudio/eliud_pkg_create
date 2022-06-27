if "%1"=="PUB_GET" call flutter pub get
del lib\model\*.dart
call flutter packages pub run build_runner build --delete-conflicting-outputs 
