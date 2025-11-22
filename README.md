# TodoFlow 프로젝트 개요

이 문서는 Flutter 기반의 프론트엔드 애플리케이션(TodoFlow)과 FastAPI 기반의 백엔드 서비스로 구성된 TodoFlow 프로젝트에 대한 리뷰 내용을 담고 있습니다.

## 1. 프론트엔드 애플리케이션 (`lib` 폴더)

Flutter 애플리케이션은 Riverpod를 사용하여 상태 관리를 하며, `riverpod_annotation`을 통해 코드 생성을 활용합니다. `lib` 폴더의 구조는 기능별로 잘 분리되어 있습니다.

### 주요 컴포넌트 요약:

*   **`main.dart`**: 애플리케이션의 진입점. Riverpod의 `ProviderScope`로 래핑되어 있으며, 인증 흐름을 담당하는 `AuthGate`를 초기 화면으로 설정합니다. 로그인, 회원가입, 보드 목록, 투두 목록 화면으로의 라우트를 정의합니다.
*   **`providers.dart` / `providers.g.dart`**: 전역 상태 관리를 위한 Riverpod 프로바이더들을 정의합니다. `StateProvider`와 `Provider`뿐만 아니라 `riverpod_annotation`을 사용한 코드 생성 프로바이더의 예시를 포함합니다. `providers.g.dart`는 이들 프로바이더의 생성된 코드를 담고 있습니다.
*   **`repositories.dart` / `repositories.g.dart`**: 데이터 페칭을 위한 `FruitRepository`와 이를 제공하는 Riverpod 프로바이더를 정의합니다. Riverpod를 통한 의존성 주입 및 비동기 데이터 처리 패턴을 보여줍니다. `repositories.g.dart`는 생성된 리포지토리 프로바이더 코드를 포함합니다.
*   **`api` 폴더 (`api_service.dart`)**: `ApiService` 클래스를 포함하며, FastAPI 백엔드와의 모든 API 통신을 담당합니다. 사용자 인증(로그인, 회원가입), 보드 관리(생성, 읽기, 업데이트, 삭제), 투두 항목 관리(생성, 업데이트, 삭제) 기능을 제공합니다. `shared_preferences`를 사용하여 액세스 토큰을 저장하고, `http` 패키지로 네트워크 호출을 수행합니다.
*   **`auth` 폴더 (`auth_gate.dart`)**: `AuthGate` 위젯은 사용자 인증 상태를 관리하고, 로그인 여부에 따라 `LoginScreen` 또는 `BoardListScreen`으로 리디렉션합니다. Riverpod의 `authProvider`를 통해 인증 상태를 관찰합니다.
*   **`models` 폴더 (`user.dart`, `board.dart`, `todo_item.dart`)**: 백엔드 API와 일관된 데이터 모델(User, Board, TodoItem)을 정의합니다. 각 모델은 `fromJson`, `toJson` 메서드를 포함하여 직렬화/역직렬화를 처리하며, `copyWith` 메서드로 불변성을 지원합니다.
*   **`music_player` 폴더**: 음악 플레이어 기능을 위한 전용 모듈입니다.
    *   **`data` (`songs.dart`)**: `Song` 객체 리스트인 `songPlaylist`를 정의하며, 음악 플레이어의 목업 데이터 또는 초기 재생 목록으로 사용됩니다.
    *   **`models` (`song.dart`)**: `title`, `artist`, `albumArtPath`, `audioPath` 속성을 가진 불변 `Song` 클래스를 정의합니다.
    *   **`providers` (`audio_player_provider.dart`, `i_audio_player.dart`)**: `IAudioPlayer` 인터페이스를 정의하고, `AudioPlayerAdapter`를 통해 `audioplayers` 패키지의 `AudioPlayer`를 래핑합니다. `AudioPlayerNotifier`는 음악 플레이어의 상태를 관리하고 재생 제어 기능을 제공합니다. Riverpod를 활용한 잘 구조화된 상태 관리 및 의존성 분리를 보여줍니다.
    *   **`screens` (`music_player_screen.dart`)**: 음악 플레이어의 UI를 담당하는 위젯입니다. `audioPlayerProvider`를 관찰하여 UI를 업데이트하고, `ProgressBar` 및 `PlayerControls` 위젯과 통합됩니다.
    *   **`widgets` (`player_controls.dart`, `progress_bar.dart`)**: 음악 플레이어의 재생 제어 및 진행률 표시를 위한 재사용 가능한 위젯을 포함합니다.
*   **`notifiers` 폴더**: 현재 비어 있습니다. 잠재적인 상태 관리 로직을 위한 플레이스홀더일 수 있습니다.
*   **`providers` 폴더 (`auth_provider.dart`, `board_provider.dart`, `todo_provider.dart`)**: 인증(`AuthNotifier`), 보드 목록(`boardListProvider`), 특정 보드의 투두 항목(`BoardNotifier`) 상태를 관리하는 Riverpod 프로바이더를 정의합니다. 낙관적 UI 업데이트와 백엔드와의 상호작용 로직이 포함되어 있습니다.
*   **`screens` 폴더 (`board_list_screen.dart`, `login_screen.dart`, `register_screen.dart`, `todo_list_screen.dart`)**: 애플리케이션의 주요 UI 화면들을 포함합니다.
    *   **`LoginScreen` / `RegisterScreen`**: 사용자 로그인 및 회원가입 UI를 제공하며, `authProvider.notifier`를 통해 인증 로직과 상호작용합니다.
    *   **`BoardListScreen`**: `boardListProvider`를 사용하여 보드 목록을 표시하고, 보드 생성, 편집, 삭제 기능을 제공합니다. 보드를 탭하면 해당 보드의 투두 목록 화면으로 이동합니다.
    *   **`TodoListScreen`**: 특정 보드의 투두 항목 목록을 표시하고, 투두 항목 추가, 편집, 완료/미완료 처리, 삭제 기능을 제공합니다.

## 2. 백엔드 서비스 (`backend` 폴더)

FastAPI 기반의 백엔드 서비스는 SQLite 데이터베이스를 사용하며, SQLAlchemy ORM을 통해 데이터베이스와 상호작용합니다. API 엔드포인트는 인증 및 권한 부여를 철저히 관리합니다.

### 주요 컴포넌트 요약:

*   **`main.py`**: FastAPI 애플리케이션의 진입점입니다. 데이터베이스 테이블을 생성하고, `auth`, `boards`, `todos` 라우터를 포함하여 API의 핵심 기능을 정의합니다.
*   **`database.py`**: SQLAlchemy를 사용하여 SQLite 데이터베이스(`sql_app.db`) 연결을 설정합니다. `SessionLocal`로 데이터베이스 세션을 생성하고, `Base`는 ORM 모델의 기본 클래스 역할을 합니다. `get_db`는 데이터베이스 세션을 제공하는 의존성 주입 함수입니다.
*   **`models.py`**: SQLAlchemy ORM 모델인 `User`, `Board`, `TodoItem`을 정의합니다. `Board` 모델은 `TodoItem`과의 관계에서 `cascade="all, delete-orphan"`을 사용하여 보드 삭제 시 투두 항목도 함께 삭제되도록 합니다.
*   **`schemas.py`**: Pydantic 모델(스키마)을 정의하여 API의 데이터 유효성 검사 및 직렬화/역직렬화를 처리합니다. `User`, `Token`, `TodoItem`, `Board`에 대한 다양한 스키마(기본, 생성, 업데이트, 응답)를 포함하며, `Config.orm_mode = True`로 ORM 통합을 지원합니다.
*   **`crud.py`**: 데이터베이스와의 CRUD(생성, 읽기, 업데이트, 삭제) 작업을 위한 함수들을 포함합니다. 사용자, 보드, 투두 항목 관리를 위한 기능을 제공하며, `security.get_password_hash`를 사용하여 비밀번호를 해싱합니다.
*   **`security.py`**: FastAPI 애플리케이션의 인증 및 권한 부여를 담당합니다. `passlib.context.CryptContext`를 사용한 비밀번호 해싱, JWT 토큰 생성 및 검증(`create_access_token`, `decode_access_token`), OAuth2 토큰 기반 인증(`OAuth2PasswordBearer`), 그리고 현재 사용자 추출(`get_current_user` 의존성) 기능을 제공합니다. **`SECRET_KEY`는 프로덕션 환경에서 반드시 강력하고 무작위로 생성된 값으로 변경해야 합니다.**
*   **`routers` 폴더 (`auth.py`, `boards.py`, `todos.py`)**: API 엔드포인트를 정의합니다.
    *   **`auth.py`**: 사용자 등록(`/users/register`) 및 로그인(`/users/token`) 엔드포인트를 포함합니다.
    *   **`boards.py`**: 보드 생성, 조회, 업데이트, 삭제 엔드포인트(`/boards/`, `/boards/{board_id}`)를 정의하며, 모든 작업은 현재 사용자 소유권 및 인증을 확인합니다.
    *   **`todos.py`**: 특정 보드 내의 투두 항목을 관리하는 엔드포인트(`/boards/{board_id}/todos/`, `/boards/{board_id}/todos/{todo_id}`)를 정의하며, 보드 소유권 및 인증을 철저히 확인합니다.

---