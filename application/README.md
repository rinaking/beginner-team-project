# 필체크

알약 사진을 학습된 YOLO 모델로 식별하고, 복용 일정을 기록하는 로컬 MVP입니다.

현재 모델은 **118개 의약품**만 식별할 수 있습니다. 약 이름, 성분, 제조사 등은 `drug_mapping.json`에 있는 값만 사용합니다. 효능, 용법, 주의사항, 병용금기 데이터는 연결되지 않았으며, 없는 정보를 만들어 보여주지 않습니다. 상호작용 정보가 없다는 것은 함께 먹어도 안전하다는 뜻이 아닙니다.

## 주요 기능

- 알약 사진 촬영 또는 갤러리 업로드 후 `POST /predict`로 식별
- 인식 신뢰도, 전문/일반 구분, 성분, 제조사 표시
- 사진 위 인식 위치 표시. 좌표 숫자와 내부 코드는 화면에 보이지 않음
- 지원 약 이름 검색 후 내 복용약 등록
- 시작일, 종료일, 하루 여러 복용 시간, 메모
- 오늘 복용 일정, 복용 완료와 취소, 날짜별 기록
- 단일 사용자. 회원가입과 로그인은 없음

## 프로젝트 구조

```
pill-app/
├── backend/
│   ├── main.py
│   ├── routers/
│   ├── services/
│   ├── database/
│   ├── schemas/
│   ├── tests/
│   └── model/
│       ├── best.pt
│       ├── class_mapping.json
│       └── drug_mapping.json
├── data/              # SQLite 파일. 실행 시 생성
└── mobile/            # Flutter 앱 소스
```

복용 기록 DB는 `data/pill.db`입니다. `backend` 밖에 두어 서버 reload가 저장할 때마다 재시작하지 않습니다.

## Backend 실행

Python 3.12 가상환경이 `backend/.venv`에 있습니다.

```bash
cd backend
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

서버 주소는 `http://127.0.0.1:8000` 입니다. 같은 Mac의 iOS 시뮬레이터는 이 주소로 접속합니다. 실제 휴대폰에서 접속하려면 컴퓨터와 폰이 같은 Wi-Fi여야 하고, 위처럼 `0.0.0.0`으로 실행한 뒤 컴퓨터의 LAN IP를 사용합니다.

API 문서는 `http://127.0.0.1:8000/docs` 입니다.

모델은 서버 시작 시 한 번 로드됩니다. 추론 이미지 크기는 768입니다.

## API

| Method | Path | 설명 |
| --- | --- | --- |
| POST | `/predict` | 이미지 한 장. 필드 이름 `file` |
| GET | `/meta` | 지원 약 개수 |
| GET | `/drugs/search?q=` | 약 이름 검색 |
| GET | `/drugs/{k_code}` | 약 상세 |
| GET | `/medications` | 내 복용약 |
| POST | `/medications` | 등록 |
| GET | `/medications/{id}` | 조회 |
| PUT | `/medications/{id}` | 수정 |
| DELETE | `/medications/{id}` | 삭제 |
| GET | `/schedules/today` | 오늘 일정 |
| GET | `/schedules?date=YYYY-MM-DD` | 특정 날짜 일정 |
| GET | `/history?date=YYYY-MM-DD` | 복용 기록 |
| POST | `/schedules/taken` | 복용 완료 |
| POST | `/schedules/cancel` | 복용 완료 취소 |
| POST | `/interactions/check` | 상호작용 조회 |

`/interactions/check`는 공식 데이터가 연결되기 전에는 `data_available: false`와 빈 목록만 반환합니다.

선택 환경 변수는 `backend/.env.example`을 복사해 `backend/.env`로 둡니다. `.env`는 git에 포함하지 않습니다. API 키는 코드에 넣지 않습니다.

CORS는 기본적으로 localhost만 허용합니다. 모든 origin을 열려면 `CORS_ORIGINS=*`를 직접 넣어야 하며, 운영 환경용 설정이 아닙니다.

## Flutter 실행

앱 소스는 `mobile/lib`에 있습니다. 이 Mac에는 Flutter SDK가 설치되어 있지 않아 iOS/Android 프로젝트 폴더와 실행 확인은 아직 되지 않았습니다.

1. [Flutter SDK](https://docs.flutter.dev/get-started/install/macos)를 설치합니다. iOS 실행에는 Xcode도 필요합니다.
2. 플랫폼 폴더를 생성합니다.

```bash
cd mobile
flutter create --platforms=ios,android --project-name pill_app --org com.pillapp .
flutter pub get
```

`flutter create`가 `pubspec.yaml`의 의존성을 지우면 아래를 다시 넣습니다.

- `flutter_localizations` (Flutter SDK)
- `http`
- `image_picker`
- `provider`

3. 권한을 추가합니다.

`ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>알약 사진을 촬영하여 약을 찾습니다.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>갤러리에서 알약 사진을 선택하여 약을 찾습니다.</string>
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key>
  <true/>
</dict>
```

`android/app/src/main/AndroidManifest.xml`의 `manifest` 안에 추가합니다.

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

로컬 HTTP 서버에 접속하려면 `application` 태그에 `android:usesCleartextTraffic="true"`를 개발 중에만 넣습니다.

4. 백엔드를 실행한 뒤 앱을 실행합니다.

```bash
flutter run
```

## API 주소

주소는 `mobile/lib/config/app_config.dart`의 `AppConfig.apiBaseUrl` 한 곳만 바꿉니다. 실행 시 덮어쓸 수도 있습니다.

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

| 환경 | 주소 |
| --- | --- |
| iOS Simulator | `http://127.0.0.1:8000` |
| Android Emulator | `http://10.0.2.2:8000` |
| 실제 휴대폰 | `http://<컴퓨터 LAN IP>:8000` |

인식 신뢰도 안내가 나타나는 기준은 같은 파일의 `lowConfidenceThreshold`입니다. 기본값은 `0.7`입니다.

## 필요한 프로그램

- Python 3.12와 `backend/.venv`
- Flutter SDK
- iOS: Xcode
- Android: Android Studio 또는 Android SDK

## 구현된 기능

- YOLO `best.pt` 식별과 K-code, 약 정보 연결
- 118개 약 검색
- 복용약 등록, 수정, 삭제
- 오늘 일정, 복용 완료, 취소, 날짜별 기록
- 상호작용 API 자리. 공식 소스가 없으면 빈 결과만 반환
- Flutter 화면: 홈, 약 찾기, 인식 결과, 상세, 내 복용약, 검색, 등록/수정, 복용 기록

## 아직 연결되지 않은 기능

공식 의약품 API가 없습니다. 그래서 아래는 화면에 자리를 만들어 두었고, 데이터는 비어 있습니다.

- 효능·효과
- 용법·용량
- 주의사항
- 병용금기 / 약물 상호작용
- 새로 인식한 약과 현재 복용약의 실제 비교 경고

환경 변수 `INTERACTION_API_BASE_URL`과 `INTERACTION_API_KEY`만 준비되어 있습니다. 값을 넣어도 검증된 조회 코드가 없기 때문에 임의 결과를 만들지 않습니다.

회원가입, 로그인, 알림 푸시, 스토어 배포는 이번 MVP에 포함하지 않았습니다.
