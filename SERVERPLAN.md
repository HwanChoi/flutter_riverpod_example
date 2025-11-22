### **프로젝트: 무한 Todo 게시판 및 리스트 앱 (가칭: "TodoFlow")**

---

### **최상위 목표**

[x] 사용자 인증을 기반으로, 여러 개의 Todo 게시판(Board)을 생성하고, 각 게시판 내에서 Todo 아이템(Item)을 효율적으로 관리할 수 있는 REST API 서버와 이를 사용하는 Flutter 클라이언트 앱을 개발합니다.

---

### **Phase 1: 백엔드 개발 (FastAPI)**

이 단계에서는 앱의 핵심 로직과 데이터를 처리하는 안정적인 API 서버를 구축합니다.

**1단계: FastAPI 백엔드 환경 설정 및 구조 설계**
*   **작업:**
    *   [x] `backend` 디렉토리 생성하여 프로젝트 분리.
    *   [x] Python 가상환경 설정 (`venv`).
    *   [x] 필수 라이브러리 설치: `fastapi`, `uvicorn`, `sqlalchemy`, `pydantic`, `python-jose[cryptography]`, `passlib[bcrypt]`, `python-multipart`.
    *   [x] 확장성을 고려한 프로젝트 구조 설계:
        ```
        /backend
        ├── main.py         # API 서버 시작점
        ├── database.py     # 데이터베이스 연결 및 세션 관리
        ├── models.py       # SQLAlchemy DB 모델 (User, Board, Todo)
        ├── schemas.py      # Pydantic 데이터 검증 스키마
        ├── crud.py         # 데이터 처리 함수 (Create, Read, Update, Delete)
        ├── security.py     # 인증/보안 관련 함수 (JWT, 비밀번호 해싱)
        └── routers/
            ├── auth.py     # 인증 API
            ├── boards.py   # 게시판 API
            └── todos.py    # Todo 아이템 API
        ```

**2단계: 사용자 인증 시스템 구축 (JWT 기반)**
*   **작업:**
    *   [x] `User` 모델 및 스키마 정의 (username, hashed_password).
    *   [x] **회원가입 API**: `POST /api/users/register` 구현.
    *   [x] **로그인 API**: `POST /api/auth/token` 구현 (로그인 성공 시 JWT 토큰 발급).
    *   [x] **토큰 검증 의존성**: API 요청 헤더의 `Authorization` 토큰을 검증하여 현재 사용자를 식별하는 `get_current_user` 함수 구현. 이 함수로 모든 핵심 API를 보호합니다.
*   **MCP 활용 방안:** `security-engineer` 에이전트를 호출하여 JWT 구현의 보안 취약점을 검토하고, 안전한 토큰 관리 방안(리프레시 토큰 등)에 대한 아키텍처를 제안받을 수 있습니다.

**3단계: Todo 게시판(Board) CRUD API 개발**
*   **작업:** `get_current_user` 의존성을 사용하여 모든 API가 인증된 사용자에게만 동작하도록 구현합니다.
    *   [x] **게시판 생성**: `POST /api/boards/` 구현.
    *   [x] **내 게시판 목록 조회**: `GET /api/boards/` 구현.
    *   [x] **특정 게시판 상세 조회**: `GET /api/boards/{board_id}` 구현.
    *   [x] **게시판 이름 수정**: `PUT /api/boards/{board_id}` 구현.
    *   [x] **게시판 삭제**: `DELETE /api/boards/{board_id}` 구현 (게시판 삭제 시 하위 Todo 아이템들도 함께 삭제 처리).

**4단계: Todo 아이템(Item) CRUD API 개발**
*   **작업:** 게시판과 마찬가지로 모든 API는 인증 및 소유권(해당 게시판의 소유주인지)을 확인합니다.
    *   [x] **아이템 생성**: `POST /api/boards/{board_id}/todos/` 구현.
    *   [x] **아이템 수정 (내용, 완료 여부)**: `PUT /api/todos/{todo_id}` 구현.
    *   [x] **아이템 삭제**: `DELETE /api/todos/{todo_id}` 구현.
    *   [x] (아이템 조회는 게시판 상세 조회 시 함께 반환하는 것으로 설계하여 효율 증대)

---

### **Phase 2: 프론트엔드 개발 (Flutter)**

이 단계에서는 구축된 API를 사용하여 사용자가 실제로 상호작용할 수 있는 모바일 앱을 개발합니다.

**5단계: Flutter 프로젝트 설정 및 구조 설계**
*   **작업:**
    *   [x] 기존 Flutter 프로젝트(`flutter_application_demo`) 내에 기능별로 디렉토리 구조화.
    *   [x] `pubspec.yaml`에 라이브러리 추가: `http` 또는 `dio` (네트워크 통신), `flutter_riverpod` (상태 관리), `shared_preferences` (인증 토큰 저장).
    *   [x] 프로젝트 구조 설계:
        ```
        /lib
        ├── api/              # API 통신 서비스
        ├── models/           # 데이터 모델 (User, Board, Todo)
        ├── providers/        # Riverpod 상태 관리 프로바이더
        ├── screens/          # 각 화면 UI (로그인, 회원가입, 게시판 목록, Todo 목록)
        ├── widgets/          # 재사용 가능한 위젯
        └── auth/             # 인증 관련 로직 및 화면
        ```

**6단계: 인증 플로우 구현 (로그인/회원가입)**
*   **작업:**
    *   [x] `로그인` 및 `회원가입` 화면 UI 구현.
    *   [x] `AuthProvider` (Riverpod)를 구현하여 사용자 인증 상태(로그인/로그아웃) 관리.
    *   [x] 로그인 성공 시, 서버로부터 받은 JWT 토큰을 `shared_preferences`에 안전하게 저장.
    *   [x] 앱 실행 시 토큰 유무/유효성을 검사하여 `로그인 화면` 또는 `게시판 목록 화면`으로 자동 이동시키는 'Auth Gate' 로직 구현.

**7단계: 게시판(Board) 관리 기능 구현**
*   **작업:**
    *   [x] **게시판 목록 화면**: `FutureProvider`를 사용하여 내 게시판 목록을 API 서버에서 가져와 `ListView`로 표시.
    *   [x] `FloatingActionButton` 등을 이용해 새 게시판을 생성하는 기능 구현 (Dialog 또는 새 화면 사용).
    *   [x] 게시판 목록에서 특정 게시판을 탭하면 해당 게시판의 Todo 목록 화면으로 이동.
    *   [x] (선택) 게시판 이름 수정 및 삭제 기능 구현.

**8단계: Todo 아이템(Item) 관리 기능 구현**
*   **작업:**
    *   [x] **Todo 목록 화면**: `board_id`를 인자로 받아, 해당 게시판의 Todo 아이템들을 서버에서 가져와 표시.
    *   [x] 아이템 추가, 수정, 삭제 UI 및 기능 구현.
    *   [x] `Checkbox` 등을 사용하여 Todo 아이템의 `완료`/`미완료` 상태를 변경하고, 즉시 서버에 반영하는 기능 구현.
    *   [x] `Dismissible` 위젯 등을 사용하여 스와이프로 아이템을 삭제하는 UX 구현.

---

### **개발 및 테스트 전략**

*   [x] **Backend-First**: API 서버의 각 엔드포인트가 Postman 또는 유사한 툴로 완벽하게 동작하는 것을 확인한 후, 이에 해당하는 Flutter UI를 개발합니다.
*   [x] **상태 관리**: Riverpod를 적극적으로 사용하여 서버 상태(Server State)와 UI 상태(UI State)를 분리하고, 앱 전반의 데이터 흐름을 일관되고 예측 가능하게 관리합니다.
*   [x] **오류 처리**: 네트워크 오류, 서버 응답 오류(4xx, 5xx) 등 다양한 예외 상황에 대비한 사용자 친화적인 오류 메시지를 Flutter 앱에 표시합니다.