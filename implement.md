### **구현 내용 문서 (implement.md)**

### **개요**

이 문서는 FastAPI 백엔드 서버와 Flutter 프론트엔드 앱으로 구성된 "TodoFlow" 애플리케이션의 현재 구현 상태를 설명합니다.

---

### **Phase 1: 백엔드 구현 (FastAPI)**

FastAPI를 사용하여 사용자 인증, 게시판 및 할일 항목 관리를 위한 RESTful API를 구축했습니다.

#### **1. 프로젝트 구조**

```
/backend
├── main.py         # API 서버 시작점 및 라우터 통합
├── database.py     # 데이터베이스 연결 및 세션 관리 (SQLite 사용)
├── models.py       # SQLAlchemy 데이터베이스 모델 (User, Board, TodoItem)
├── schemas.py      # Pydantic 데이터 검증 스키마
├── crud.py         # 데이터베이스 CRUD(생성, 읽기, 수정, 삭제) 함수
├── security.py     # 인증/보안 관련 함수 (비밀번호 해싱, JWT 생성/검증)
└── routers/
    ├── auth.py     # 인증 API (회원가입, 로그인)
    ├── boards.py   # 게시판 CRUD API
    └── todos.py    # 할일 항목 CRUD API
```

#### **2. 핵심 기능별 파일 내용**

*   **`database.py`**: SQLite 데이터베이스 (`sql_app.db`) 연결을 설정하고, API 엔드포인트에 데이터베이스 세션을 주입하는 `get_db` 의존성을 제공합니다.

*   **`models.py`**:
    *   `User`: 사용자 모델. `id`, `username`, `hashed_password`, `is_active` 필드를 가집니다. `Board`와 1:N 관계를 설정합니다.
    *   `Board`: 게시판 모델. `id`, `title`, `owner_id` (외래 키) 필드를 가집니다. `User` 및 `TodoItem`과 관계가 설정되어 있습니다.
    *   `TodoItem`: 할일 항목 모델. `id`, `description`, `completed`, `board_id` (외래 키) 필드를 가집니다.

*   **`schemas.py`**:
    *   API 요청/응답 본문의 데이터 유효성 검사를 위한 Pydantic 모델들을 정의합니다. (`User`, `UserCreate`, `Board`, `BoardCreate`, `TodoItem`, `TodoItemCreate`, `Token` 등)
    *   `orm_mode = True`를 사용하여 SQLAlchemy 모델과 호환됩니다.

*   **`security.py`**:
    *   `pwd_context`를 사용하여 `bcrypt`로 비밀번호를 안전하게 해싱하고 검증합니다.
    *   JWT 토큰 생성을 위한 `create_access_token` 함수와 토큰 검증 및 사용자 조회를 위한 `get_current_user` 의존성을 구현했습니다. `OAuth2PasswordBearer`를 사용하여 토큰은 `Authorization: Bearer <token>` 헤더를 통해 전달됩니다.

*   **`crud.py`**:
    *   데이터베이스와 직접 상호작용하는 함수들을 포함합니다.
    *   `create_user`, `get_user_by_username`, `create_user_board`, `get_boards`, `update_board_title`, `delete_board`, `create_board_todo_item`, `update_todo_item`, `delete_todo_item` 등의 함수가 구현되어 각 라우터에서 사용됩니다.

*   **`routers/auth.py`**:
    *   `POST /users/register`: 새 사용자를 등록합니다.
    *   `POST /users/token`: 사용자 로그인 후 JWT 액세스 토큰을 발급합니다.

*   **`routers/boards.py`**:
    *   `get_current_user` 의존성으로 모든 엔드포인트를 보호합니다.
    *   `POST /boards/`: 새 게시판 생성.
    *   `GET /boards/`: 현재 로그인된 사용자의 모든 게시판 조회.
    *   `GET /boards/{board_id}`: 특정 게시판 상세 조회 (소유권 확인).
    *   `PUT /boards/{board_id}`: 게시판 이름 수정 (소유권 확인).
    *   `DELETE /boards/{board_id}`: 게시판 삭제 (소유권 확인).

*   **`routers/todos.py`**:
    *   `get_current_user` 의존성으로 모든 엔드포인트를 보호합니다.
    *   `POST /boards/{board_id}/todos/`: 특정 게시판에 새 할일 항목 생성.
    *   `PUT /boards/{board_id}/todos/{todo_id}`: 할일 항목 수정 (소유권 확인).
    *   `DELETE /boards/{board_id}/todos/{todo_id}`: 할일 항목 삭제 (소유권 확인).

*   **`main.py`**:
    *   FastAPI 앱 인스턴스를 생성하고, `auth`, `boards`, `todos` 라우터를 포함합니다.
    *   앱 시작 시 `Base.metadata.create_all(bind=engine)`을 호출하여 데이터베이스 테이블을 생성합니다.

---

### **Phase 2: 프론트엔드 구현 (Flutter)**

Flutter와 `flutter_riverpod`를 사용하여 API 서버와 상호작용하는 모바일 앱을 구현했습니다.

#### **1. 프로젝트 구조**

```
/lib
├── api/
│   └── api_service.dart      # 모든 API 통신 로직
├── models/
│   ├── user.dart             # User 데이터 모델
│   ├── board.dart            # Board 데이터 모델
│   └── todo_item.dart        # TodoItem 데이터 모델
├── providers/
│   ├── auth_provider.dart    # 사용자 인증 상태 관리
│   └── board_provider.dart   # 게시판 목록 조회
│   └── todo_provider.dart    # 특정 게시판 상세 정보(todos 포함) 조회
├── screens/
│   ├── login_screen.dart     # 로그인 화면 UI
│   ├── register_screen.dart  # 회원가입 화면 UI
│   ├── board_list_screen.dart# 게시판 목록 화면 UI
│   └── todo_list_screen.dart # 할일 목록 화면 UI
└── auth/
    └── auth_gate.dart        # 인증 상태에 따라 화면을 분기하는 위젯
```

#### **2. 핵심 기능별 파일 내용**

*   **`api/api_service.dart`**:
    *   `http` 패키지를 사용하여 FastAPI 서버와 통신합니다.
    *   `_getAuthHeaders`: `shared_preferences`에서 JWT 토큰을 가져와 인증 헤더를 생성합니다.
    *   `login`, `register`, `getBoards`, `createBoard`, `updateBoard`, `deleteBoard`, `getBoard`, `createTodoItem`, `updateTodoItem`, `deleteTodoItem` 등 백엔드 API에 대응하는 모든 메서드를 구현했습니다.

*   **`models/`**: `user.dart`, `board.dart`, `todo_item.dart` 파일에 각각 서버 응답에 맞춰 JSON 데이터를 Dart 객체로 변환하는 `fromJson` 팩토리 생성자와 `toJson` 메서드를 포함한 클래스들을 정의했습니다.

*   **`providers/`**:
    *   `auth_provider.dart`: `StateNotifierProvider`를 사용하여 앱의 전역적인 사용자 인증 상태(`User` 객체 또는 `null`)를 관리합니다. `login`, `logout`, `register` 등의 비즈니스 로직을 포함합니다.
    *   `board_provider.dart`: `FutureProvider`를 사용하여 `ApiService`의 `getBoards`를 호출하고, 게시판 목록을 비동기적으로 가져옵니다.
    *   `todo_provider.dart`: `FutureProvider.family`를 사용하여 특정 `boardId`에 해당하는 게시판의 상세 정보(할일 목록 포함)를 비동기적으로 가져옵니다.

*   **`auth/auth_gate.dart`**:
    *   `authProvider`를 `watch`하여 인증 상태 변경을 감지합니다.
    *   로그인 상태이면 `BoardListScreen`을, 로그아웃 상태이면 `LoginScreen`을 보여주어 화면을 자동으로 전환합니다.

*   **`screens/login_screen.dart` & `screens/register_screen.dart`**:
    *   `TextField`와 `ElevatedButton`으로 구성된 기본적인 로그인/회원가입 UI를 제공합니다.
    *   각 버튼 클릭 시 `authProvider`의 `login` 또는 `register` 메서드를 호출합니다.

*   **`screens/board_list_screen.dart`**:
    *   `boardListProvider`를 `watch`하여 게시판 목록을 표시합니다.
    *   `FutureProvider`의 상태(`data`, `loading`, `error`)에 따라 각각 다른 UI를 보여줍니다.
    *   `FloatingActionButton`을 통해 새 게시판을 생성하는 다이얼로그를 띄웁니다.
    *   `ListTile`의 `onTap`으로 `TodoListScreen`으로 이동하고, `onLongPress`로 수정/삭제 옵션을 포함한 `BottomSheet`를 띄웁니다.

*   **`screens/todo_list_screen.dart`**:
    *   `boardProvider(boardId)`를 `watch`하여 특정 게시판의 할일 목록을 표시합니다.
    *   `Checkbox`를 통해 할일의 완료 상태를 변경합니다.
    *   `Dismissible` 위젯을 사용하여 스와이프로 할일을 삭제하는 기능을 구현했습니다.
    *   `ListTile`의 `onTap`으로 할일 내용을 수정하는 다이얼로그를 띄웁니다.

*   **`main.dart`**:
    *   `ProviderScope`로 앱 전체를 감싸 Riverpod를 활성화합니다.
    *   `home`을 `AuthGate`로 설정하여 앱 시작 시 인증 상태를 확인합니다.
    *   `/login`, `/register`, `/boards`, `/todos` 등 앱 내 화면 이동을 위한 `routes`를 정의합니다.
