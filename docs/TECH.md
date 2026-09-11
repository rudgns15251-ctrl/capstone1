# TECH.md

## 문서 범위와 기준

상태: 첫 번째 의뢰 Prototype의 구현 설계. 이 문서 작성 시 실제 Godot 구현·실행 검증은 하지 않았다.

- 기준: 이번에 제공된 수정본 GAME.md와 STORY.md. 이전 검토본의 권장안을 확정 설정으로 사용하지 않는다.
- GAME.md는 게임 규칙, STORY.md는 이야기와 의뢰의 Source of Truth다. 이 문서는 두 문서를 변경하지 않는다.
- 대상: STORY.md의 `SR-001 개인정보 노출 게시물 정리 요청` 한 건, 첫 플레이 약 5~15분.
- 환경: Godot 4.x, GDScript, Windows. 실제 구현 시작 시 설치된 안정 버전 하나를 확인하여 ROADMAP.md에 기록한다. 임의 엔진 업그레이드를 하지 않는다.
- 아래 경로·ID·데이터 필드·화면 배치·처리 UX·Milestone은 기술적 설계안이다. 게임 세계의 새 설정이 아니다.
- 정확한 게시물 제목·직원 이름·URL·사진 파일명·계약 날짜·메일 본문·완료 답신은 원문에 확정되어 있지 않다. 표시용 임시값은 데이터의 작성 메모에 표시하며, 미정인 신분·후반 비밀·새 사건을 채워 넣지 않는다.

## 1. Prototype 목표와 판정

검증 질문: 검색 → 인터넷 탐색 → 단서 발견 → 추가 조사 → 수정/삭제가 실제로 재미있는가?

검증할 플레이 경험:

1. 초기 정보로 검색어를 만들 수 있다.
2. 검색 결과의 제목·작성자·요약을 보고 갈 곳을 선택할 수 있다.
3. blueframe과 원본 이미지 정보를 이용해 다른 출처를 찾아간다.
4. TalkBoard의 연결 이미지와 MyRoom의 별도 재업로드를 구분한다.
5. 처리 대상과 작업 종류를 직접 정하고, 처리 뒤 웹페이지가 달라진 것을 확인한다.
6. 설명문 없이 사진 전체를 지운 결과와 작은 이상함을 경험한다.

5~15분은 첫 플레이의 목표 범위이며 강제 대기시간이나 통과 조건이 아니다. 익숙한 재플레이는 더 짧아도 된다. 조작 불편·암기·정답 검색어 맞히기로 시간을 늘리지 않는다.

## 2. 첫 번째 의뢰를 플레이 단계로 변환

| 단계 | 확정 근거 | Prototype의 행동·화면 | 구현 시 주의 |
|---|---|---|---|
| 업무 시작 | 기업 관리 업무용 PC, 외부 계약자 Level 1 | 바탕화면 → PostOne 의뢰 열람, S-LINK에서 업무 정보 확인 | 초기 업무 이메일·계약 날짜·업무 ID·사용자 이름을 표시한다. 값은 임시 데이터이며 새 개인사를 만들지 않는다. |
| 기업 의뢰 | 직원 개인정보 노출 정리, SR-001 | 직원 실명 비식별화와 사진 원본·확인된 재업로드 삭제 범위를 읽음 | 실제 은폐 목적·C동의 의미·R-12 연구를 의뢰문에 설명하지 않는다. |
| 최초 정보 | 기업명, 직원 개인정보가 노출된 게시물이라는 의뢰 | 세린생명과학과 해당 게시물의 검색용 표현으로 FindOn 검색 | 정확한 시작 검색 문구는 미정. 확정된 의뢰 내용을 식별할 수 있는 문구만 데이터로 작성한다. 처음부터 전체 정답 URL 목록을 주지 않는다. |
| 첫 방문 | TalkBoard 게시물, blueframe 계정 | 결과를 비교해 게시물 열기, 본문 실명·작성자·연결 사진 확인 | blueframe이 게시자임을 필수 화면에 표시한다. |
| 원본 조사 | TalkBoard는 PicBox 원본을 불러옴 | 사진 출처 링크 → PicBox에서 이미지·업로더·파일명 확인 | C동과 냉동 운송 차량이 사진에서 보인다. Chapter 1의 필수 검색 코드로 R-12를 추가하지 않는다. |
| 추가 조사 | blueframe, MyRoom의 동일 이미지 | 닉네임 또는 화면에서 확인한 파일명 재검색 → MyRoom HOME/PHOTO 조사 | 닉네임·이미지 정보가 재검색의 근거가 된다. 파일명 자체는 임시값이며 원본·검색 자료에서 일관되어야 한다. |
| 비교·판단 | MyRoom은 원본과 별도로 존재하는 재업로드 | PicBox와 MyRoom 이미지를 브라우저 기록으로 오가며 비교 | 동일 시각 자료지만 서로 다른 게시 위치·개별 이미지 기록이다. 정답 팝업이나 추리 미니게임을 추가하지 않는다. |
| 선택 탐색 | C동·새벽 차량 관련 과거 글 | MyRoom DIARY의 기존 맥락 확인 | 완료 조건에서 제외한다. blueframe의 고용 형태나 실종을 임의로 확정하지 않는다. |
| 대상 등록 | 조사한 URL·파일을 S-LINK에 등록 | 가상 주소 복사 → S-LINK 주소 입력 → 페이지 내 항목 선택 → 대상 등록 | 미발견 대상의 위치를 시스템이 먼저 알려주지 않는다. 잘못된 대상을 선택하면 비파괴적으로 거부한다. |
| 처리 | 본문 비식별화 + 원본 삭제 + 재업로드 삭제 | 등록 항목과 작업 종류 선택 → 처리 범위 미리보기 → 실행 | 본문 전체·계정 전체 삭제를 허용하지 않는다. 이미지 픽셀 편집은 없다. |
| 결과 확인 | 원본 삭제 시 TalkBoard 이미지 소멸, 별도 복사본은 별개 | 페이지를 다시 방문해 본문·이미지 상태 비교 | 원본을 먼저 지워도 재업로드를 찾는 경로가 남아야 한다. |
| 완료 보고 | 수정/삭제 후 기업에 보고 | 세 처리 조건 충족 후 보고 → 친절하고 업무적인 완료 답신 | 답신의 정확한 문구·보상은 미정. 새 의뢰·Level 2·보상 지급을 구현하지 않는다. |
| 작은 이상현상 | 삭제 직후 FindOn에 같은 썸네일이 잠깐 재등장 | 마지막 필수 이미지 삭제 후 처음 보이는 관련 검색 결과에서 1회 노출 | 원본이 복구된 것이 아니다. 클릭해도 삭제 상태다. 별도 효과음·점프스케어를 붙이지 않는다. |

탐색 순서는 권장 동선이지 강제 방문 순서가 아니다. MyRoom을 먼저 찾아도 된다. 시스템은 방문 순서나 특정 검색어 입력 횟수로 정답을 판정하지 않는다.

이상현상은 '삭제 직후'라는 원문을 지킨다. 마지막 이미지 처리 후 S-LINK에 처리 위치 재확인용 FindOn 링크를 제공한다. 다른 화면을 보는 동안 타이머가 소진되지 않게 관련 결과가 실제 보일 때 짧게 노출한다. 완료 보고 전후 어느 쪽에 보더라도 같은 1회 사건이며, 기업 답신이 사건을 발생시키는 새 설정은 넣지 않는다.

## 3. Scope

### MUST HAVE

- 고정된 업무용 Desktop 한 화면, Browser와 PostOne 전환.
- FindOn 검색 입력·결과 비교·결과 없음 상태.
- 주소 입력, 페이지 내 링크, 뒤로/앞으로, 스크롤 위치 복원.
- TalkBoard, PicBox, MyRoom의 첫 의뢰용 페이지만 표시.
- blueframe·원본 출처·이미지 메타데이터와 재업로드의 비교.
- S-LINK 대상 등록, 비식별화/이미지 삭제, 승인 범위 확인, 결과 보고.
- 단일 세션의 처리 상태 유지와 처음부터 다시 시작.
- 완료 답신 1통, 삭제 썸네일 잔여 연출 1종.
- 조사에 필요한 사진 1종과 읽을 수 있는 임시 UI. 동일 사진의 원본·재업로드·썸네일은 시각 에셋을 재사용한다.

### LATER

Prototype 검증 후 전체 게임 개발에서 다룰 대상이다. 구체 구조를 미리 만들지 않는다.

- Chapter 2~6 및 해당 의뢰·자료·접근 제한·엔딩.
- 실제 분량이 정해진 뒤의 저장/이어하기.
- 최종 UI·음향·이미지 품질, 배포용 옵션과 해상도 정책.
- 플레이테스트에서 필요성이 확인된 힌트·탐색 편의 개선.
- Steam 배포 준비. 업적·다국어는 필요성 판단 후 별도 범위 결정.

### DO NOT BUILD YET

- 실제 인터넷, HTML/CSS 엔진, Chromium/WebView, HTTP 서버, 외부 계정 인증.
- LLM 검색, 웹 크롤러, 벡터 검색, 전문 검색 라이브러리.
- 임의 문서 편집기, 포토샵형 이미지 편집, OCR, 이미지 자동 비교.
- 자유로운 창 이동·크기 변경·다중 창·다중 탭·가상 파일시스템·완전한 OS.
- Messenger 별도 구현, MyRoom 전체 서비스, DailyNet 등 후속 사이트.
- 신뢰도 수치, 범용 퀘스트 그래프, 이벤트 버스 Autoload, 범용 Horror Manager.
- CMS, 콘텐츠 편집 플러그인, 모드 시스템, 세이브 마이그레이션, 클라우드 저장.
- Steam SDK·업적·다국어·완성형 설정·모든 Chapter를 위한 빈 코드와 데이터.

## 4. 전체 아키텍처

선택: 하나의 Main을 유지하고 그 안에서 화면을 전환한다. Scene 교체로 진행 상태를 운반할 필요가 없으므로 Autoload는 0개다.

구성은 UI / 세션 상태 / 읽기 전용 콘텐츠의 세 부분이다. 별도 서비스 계층·저장소 인터페이스·Manager 계층은 만들지 않는다.

| 부분 | 소유·책임 | 경계 |
|---|---|---|
| Main | 객체 생성, 화면 연결, 의도 signal을 상태 변경으로 연결 | 검색 매칭·삭제 조건·본문 렌더링을 직접 구현하지 않음 |
| ContentCatalog | JSON 읽기, ID/주소 색인, 고정 규칙 검색, 콘텐츠 검증 | 실행 중 콘텐츠 원본을 수정하지 않음 |
| SessionState | 의뢰 읽음, 발견한 항목, 등록·처리 상태, 보고 여부, 연출 1회 상태 | Node 경로·텍스트 레이아웃·이미지 픽셀을 모름 |
| Browser/WebPageView/MailView/WorkOrderView | 표시와 입력, 사용자 의도 signal | 완료 bool을 직접 바꾸거나 콘텐츠 원본을 덮어쓰지 않음 |
| Ch01CacheEvent | 첫 의뢰의 썸네일 잔여 1회 연출, 타이머 취소 | 자료 복구·의뢰 완료·검색 알고리즘을 변경하지 않음 |

### 시스템 연결

1. Main이 ContentCatalog를 생성하고 `chapter_01.json`을 읽어 검증한다.
2. Main이 해당 의뢰 데이터로 SessionState를 초기화하고 UI에 읽기 참조를 전달한다.
3. Browser는 ContentCatalog에서 주소·검색 결과를 조회하고 SessionState의 현재 처리 상태를 반영한다.
4. WorkOrderView가 대상 등록/처리/보고 의도를 signal로 보낸다.
5. Main은 그 요청을 SessionState의 검증 메서드로 전달한다.
6. 성공한 상태 변경 signal에 연결된 화면이 다시 표시된다. 뒤로 가기에서도 오래된 UI를 재사용하지 않고 최신 상태로 그린다.
7. 마지막 이미지 처리로 Ch01CacheEvent가 대기 상태가 된다. Browser의 관련 검색 결과 표시 signal로 1회 연출한다.

상위 노드가 연결을 소유한다. 화면 간 상대 경로를 하드코딩하거나 Main의 자식을 임의로 찾아 상태를 수정하지 않는다. 모든 일을 중계하는 전역 EventBus는 필요하지 않다.

## 5. 프로젝트 폴더

아래는 각 Milestone에서 필요한 때 생성할 경로다. M1에서는 Main/Desktop, Browser/PostOne/S-LINK의 최소 화면과 세션·콘텐츠 로딩 파일만 생성했으며, 이후 경로는 해당 Milestone에서 필요할 때 추가한다.

| 경로 | 용도 |
|---|---|
| `GAME.md`, `STORY.md` | 기존 Source of Truth, 보존 |
| `TECH.md`, `ROADMAP.md`, `AGENTS.md` | 현재 개발 구조·작업 상태·Codex 규칙 |
| `project.godot` | Godot 설정과 Main 지정 |
| `scenes/main.tscn` | 실행 진입점 |
| `scenes/ui/desktop.tscn` | 고정 업무 화면과 앱 표시 영역 |
| `scenes/ui/browser.tscn` | 주소·이동 기록·FindOn·페이지·S-LINK 표시 |
| `scenes/ui/web_page_view.tscn` | 공통 콘텐츠 페이지 표시 |
| `scenes/ui/mail_view.tscn` | PostOne 의뢰와 완료 답신 |
| `scenes/ui/work_order_view.tscn` | S-LINK 대상 처리 화면 |
| `scripts/main.gd` | 조립과 연결 |
| `scripts/session_state.gd` | 세션 상태·처리 검증·완료 판정 |
| `scripts/content_catalog.gd` | 로딩·색인·검색·데이터 검증 |
| `scripts/ui/browser.gd` | Browser 입력과 현재 위치 |
| `scripts/ui/web_page_view.gd` | 공통 페이지 렌더링 |
| `scripts/ui/mail_view.gd` | 메일 표시와 링크 입력 |
| `scripts/ui/work_order_view.gd` | 등록·작업·보고 UI |
| `scripts/events/ch01_cache_event.gd` | 첫 썸네일 잔여 연출 |
| `content/chapter_01.json` | 첫 의뢰의 사이트·페이지·이미지 기록·메일·처리 데이터 |
| `assets/images/ch01_facility.*` | C동·차량·개인정보 노출을 표현하는 첫 조사 이미지 |
| `assets/ui/prototype_theme.tres` | 첫 의뢰에 필요한 임시 Theme |
| `export_presets.cfg` | M5에서 Windows 로컬 배포 확인에 필요한 경우 생성 |

Desktop에는 전용 스크립트를 만들지 않는다. 정적 레이아웃과 버튼 signal 연결은 Main으로 충분하다. 콘텐츠가 생기기 전에 빈 하위 폴더·기반 클래스를 만들지 않는다.

## 6. Scene와 화면 구조

### Main Scene

| 부모 | 자식 | 역할 |
|---|---|---|
| Main(Node, main.gd) | Desktop(Control, desktop.tscn) | 전체 UI |
| Main | Ch01CacheEvent(Node, M5에서 추가) | 첫 의뢰 연출 수명 |
| Desktop | Background / UserLabel / AppButtons | 배경, 현재 사용자, Browser·PostOne 버튼 |
| Desktop | AppArea | Browser와 MailView를 같은 고정 영역에 배치, 하나만 표시 |
| AppArea | Browser | 탐색 화면 |
| AppArea | MailView | 의뢰/답신 목록과 본문 |

ContentCatalog와 SessionState는 Main이 소유하는 RefCounted 객체다. Scene Tree에 불필요한 상태 노드를 추가하지 않는다.

### Browser

- 상단: 뒤로/앞으로, 주소 입력, 이동, 주소 복사, FindOn 이동, S-LINK 이동.
- 본문: FindOn 검색 패널, WebPageView, WorkOrderView 중 현재 주소에 해당하는 하나.
- 검색 패널: 검색 입력, 결과 제목·요약·주소·필요한 썸네일, 빈 결과 안내.
- 주소는 게임 데이터 내부에서만 해석한다. 표시 주소는 가상 `.invalid` 도메인으로 두되, 정확한 주소 문자열은 임시 콘텐츠다.
- 실제 웹브라우저를 열거나 외부 네트워크로 전달하지 않는다.
- 이동 기록은 route/query/scroll 값이다. 렌더링된 Scene의 스냅샷을 저장하지 않는다.
- 새 이동 시 앞으로 기록을 지우고, 뒤로/앞으로는 현재 SessionState로 다시 그린 뒤 스크롤을 복원한다.
- 삭제된 이미지 페이지에 돌아가면 삭제된 상태를 보이며, 이전 사진이 이력에서 되살아나지 않는다.
- 기본 브라우저 기능의 무거운 구현은 하지 않는다. 탭·북마크·다운로드·페이지별 로그인은 없다.

### Mail / Messenger

- PostOne은 Desktop에서 여는 고정 MailView다. 실제 웹메일 백엔드는 없다.
- 첫 의뢰 메일과 완료 답신만 데이터로 제공한다. 초기 계약/계정 정보는 의뢰 화면·S-LINK에 포함한다.
- 의뢰 읽음과 처리 완료를 분리한다. 메일을 열었다고 의뢰가 완료되지 않는다.
- 완료 답신은 보고 성공 후 1회만 목록에 추가한다.
- 자유 답장·대화 선택지·실시간 Messenger는 첫 의뢰에 필요하지 않아 제외한다.

### Web Page 표시

- 공통 `ScrollContainer + VBoxContainer`에 고정된 소수 콘텐츠 블록을 순서대로 그린다.
- 글은 Label/RichTextLabel, 링크는 LinkButton 또는 RichTextLabel의 meta_clicked, 사진은 TextureRect로 표시한다.
- 문서 전체를 하나의 복잡한 BBCode 문자열에 넣지 않는다. 이미지·수정 대상은 별도 블록 ID를 가진다.
- 기본 블록은 text, link, image, redactable_text, comment만 지원한다. 이 다섯 종류를 넘는 범용 HTML 엔진은 만들지 않는다.
- 사이트별 표시 차이는 사이트 이름·색·제목/메타정보·탐색 링크로 충분하다. 별도 사이트 전용 거대 스크립트는 없다.
- 최초 데이터에 없는 블록 종류가 나오면 조용히 생략하지 않고 작성 오류를 표시한다.

### 이미지 표시

- 페이지 안에서 비율을 유지한 이미지와 별도 원본 보기(동일 Browser 본문에서 크게 표시)를 제공한다. 첫 이미지가 충분히 크면 추가 확대 UI는 생략한다.
- C동·차량·개인정보 노출 요소는 테스트 이미지에서도 구분 가능해야 한다. 회색 사각형만으로 최종 핵심 루프 검증을 통과시키지 않는다.
- 이미지 인식·OCR·드래그 영역 선택은 필요하지 않다. 플레이어가 시각적으로 비교한다.
- 원본/재업로드는 동일 Texture 경로를 재사용해도 되지만, 게임상의 이미지 기록 ID는 반드시 다르다.
- 디스크 파일을 실제 삭제하지 않는다. 런타임 상태만 바꾼다.

## 7. Script 책임

| Script | 기반 | 맡는 일 | 맡지 않는 일 |
|---|---|---|---|
| main.gd | Node | 데이터/상태 생성, 의존성 전달, signal 연결, 앱 전환, 재시작 | 검색 구현·삭제 승인 규칙·본문 문자열 작성 |
| content_catalog.gd | RefCounted | JSON 로딩·구조 검사, ID/주소 조회, 검색 후보 매칭 | 진행 상태 변경·정답 자동 등록·UI 노드 생성 |
| session_state.gd | RefCounted | 현재 의뢰, 노출 확인, 등록 목록, 처리 결과, 완료/보고·1회 연출 상태 | 웹페이지 레이아웃·검색 점수·Timer |
| browser.gd | Control | route/query/history/scroll, 검색 실행, 페이지 전환, 화면 노출 통지 | 완료 판정·허용 목록 수정 |
| web_page_view.gd | Control | 데이터+상태로 블록 렌더링, 링크·사진 입력, 보인 항목 통지 | 외부 사이트별 독립 로직·대상 자동 판단 |
| mail_view.gd | Control | 의뢰/답신 표시, 읽음·링크 의도 signal | 업무 완료 처리·메일 전송 네트워크 |
| work_order_view.gd | Control | 대상 입력/미리보기/작업 선택/처리 결과/보고 상태 표시 | 등록 여부나 버튼 활성만으로 처리 성공 확정 |
| ch01_cache_event.gd | Node | 대기·표시·종료, 썸네일 1회 override, 화면 전환 시 타이머 정리 | 범용 연출 그래프·콘텐츠 원본 복구 |

8개 스크립트는 최종 Prototype에서 필요한 책임 구분이며 M1에 모두 생성하지 않는다. 클래스가 짧다는 이유로 더 작은 서비스나 Manager로 쪼개지 않는다.

## 8. 데이터 구조

### 선택: JSON 한 콘텐츠 묶음

첫 의뢰는 `content/chapter_01.json` 한 파일로 작성한다. Codex가 비교·수정하기 쉽고 별도 Resource 클래스 여러 개가 필요하지 않다. JSON은 FileAccess로 읽고 JSON.parse 결과의 오류·타입을 검사한다.

커스텀 Resource 클래스는 0개다. Godot의 Texture2D·Theme·PackedScene은 일반 에셋/장면으로 사용한다. RefCounted 클래스는 데이터의 저장 형식이 아니다.

| 구역 | 필드와 의미 |
|---|---|
| sites | site_id, label, header 색상, 최소 내비게이션 표시 정보 |
| pages | page_id, site_id, route, title, author, author_route, 표시용 날짜(필요한 경우), blocks, search_terms, search_aliases, search_summary, search_image_id(있는 경우) |
| blocks | block_id, type, 유형별 내용. 처리 대상 텍스트는 원문 부분과 비식별 결과를 분리 |
| images | image_id, texture_path, filename, 표시용 업로더/출처, origin_image_id(재업로드 관계) |
| mails | mail_id, sender, subject, body, 기존 화면으로 가는 링크, 표시 조건(initial 또는 reported) |
| mission | mission_id, title, 업무 설명, required_targets, initial_mail_id, reply_mail_id |
| required_targets | target_id, page_id, block_id 또는 image_id, allowed_action(redact/delete_image), 수정 결과(필요한 경우) |
| work_identity | 업무 이메일, 계약 날짜, 업무 ID, 사용자 이름의 표시값 |
| authoring_notes | 임시값·출처 미정 항목을 기록. 게임 화면과 검색에 노출하지 않음 |

`origin_image_id`와 `required_targets`는 내부 데이터다. 화면에 '정답 재업로드'나 전체 정답 위치를 자동 표시하는 데 사용하지 않는다.

### 최소 콘텐츠 목록

아래 ID는 코드 연결용이며 실제 페이지 제목이나 이야기 설정이 아니다.

| ID | 화면 | 첫 의뢰에서 필요한 정보 |
|---|---|---|
| talkboard_post | 게시물 1개 | 본문 실명, blueframe, PicBox 연결 사진/출처 |
| picbox_original | 원본 1개 | 원본 사진과 파일명·업로더, 노출된 C동·차량 |
| myroom_home | 개인 홈 1개 | blueframe, PHOTO/DIARY 탐색 링크 |
| myroom_photo | 사진 글 1개 | 별도 재업로드 이미지 |
| myroom_diary | 선택 과거 글 1개 | 원문에서 확정된 C동·새벽 차량 관찰 맥락 |

- 콘텐츠 페이지 5개(필수 4개, 선택 1개), FindOn 결과는 동적 목록, S-LINK와 PostOne은 기능 화면이다.
- 따라서 서비스 이름은 FindOn·TalkBoard·PicBox·MyRoom·S-LINK·PostOne의 6개지만, 6개 웹앱을 따로 만드는 것이 아니다.
- 첫 의뢰 메일 1개 + 완료 답신 1개. 댓글은 STORY.md에 구체적인 필수 단서가 없으므로 있어도 평범한 짧은 문장으로 제한하며 새로운 사실을 넣지 않는다.
- 시각 사진 1종, 원본/재업로드 이미지 기록 2개, 검색 썸네일은 파생 표시다.
- MyRoom의 GUEST/LINK 전체 탭·새 사용자·무관한 검색용 사이트를 채우지 않는다. 기능 없는 클릭 요소로 탐색을 낚지 않는다.

### 블록 계약

| type | 최소 필드 | 화면 행동 |
|---|---|---|
| text | block_id, text | 단순 읽기 |
| link | block_id, label, route | 가상 주소 이동 |
| image | block_id, image_id, source_route(있는 경우) | 이미지 표시, 원본/출처 이동 |
| redactable_text | block_id, prefix, value, suffix, redacted_value | 원래 문장 안의 해당 실명 부분만 교체 |
| comment | block_id, author, text, route(있는 경우) | 댓글 표시와 선택 링크 |

BBCode는 표시 방식일 뿐 조건식·스크립트 실행 위치가 아니다. 검색어·URL 입력을 BBCode로 그대로 해석하지 않는다. 자유 입력을 이용한 정규식 전역 치환으로 실명을 가리지 않는다.

### 원본과 복사본의 핵심 연결

| 위치 | 참조 ID | 원본 삭제 후 | 재업로드 삭제 후 |
|---|---|---|---|
| TalkBoard 이미지 블록 | img_picbox_original | 이미지 없음 | 원본 상태에 따름 |
| PicBox 원본 페이지 | img_picbox_original | 이미지 삭제됨 | 원본 상태에 따름 |
| MyRoom 사진 블록 | img_myroom_copy | 계속 보임 | 이미지 삭제됨 |

두 이미지 ID가 같은 Texture를 사용해도 위 상태는 공유하지 않는다. TalkBoard 연결 사진은 네 번째 삭제 대상이 아니다. PicBox 원본과 같은 ID의 표시 위치다.

삭제 후에도 게시자·파일명·출처 링크 등 조사에 필요한 비삭제 메타정보는 남긴다. 그림만 지워졌다는 승인 범위를 지키며, 먼저 원본을 처리해도 닉네임 재검색으로 복사본을 찾을 수 있다.

## 9. Search와 Link

- 실제 검색엔진 대신 페이지 데이터의 제한된 필드를 대상으로 검색한다.
- 검색 시작 시 공백 정리·영문 소문자화. 한국어 형태소 분석이나 무제한 오타 교정은 하지 않는다.
- 화면에서 얻을 수 있는 기업명·게시물 표현·blueframe·이미지 파일명을 search_terms에 기록한다.
- 서로 같은 뜻인 짧은 표현·띄어쓰기 변형은 search_aliases로 정규화한다. 긴 별칭을 먼저 매칭하고 남은 단어들을 처리한다.
- 정규화된 질의의 모든 토큰이 페이지의 검색 필드에 대응하는 결과를 우선한다. 제목/작성자/파일명 일치 우선, 동점이면 안정적인 page_id 순으로 정렬한다. 검색어마다 별도의 GDScript 분기를 만들지 않는다.
- 원문에 실제 보인 조합인 기업명+사진 관련 표현, blueframe 단독, 파일명 단독, 닉네임+파일명을 데이터 테스트 사례로 둔다. 매칭되지 않는 긴 자연어 문장은 결과 없음으로 처리한다.
- 빈 질의에서 모든 페이지를 정답 목록처럼 보여주지 않는다. 입력 안내만 표시한다.
- 결과 없음은 검색어를 유지하며 재검색할 수 있게 한다. 새 이야기 힌트를 자동 생성하지 않는다.
- 모든 검색과 링크는 page_id/route 조회로 귀결된다. 등록되지 않은 주소는 게임 내 접근 불가 화면이다.
- 브라우저 주소와 내부 ID를 분리한다. 페이지 제목을 바꾸어도 링크와 처리 대상이 깨지지 않아야 한다.
- 검색 결과 본문 요약은 변경된 텍스트를 반영한다. 이미지 삭제 이후 정상 결과에서는 썸네일을 숨긴다. 제목·작성자·텍스트 검색 결과는 남을 수 있다.
- authoring_notes, 승인 대상 목록, origin_image_id 등 숨은 데이터는 검색하지 않는다.

## 10. 수정/삭제와 완료 판정

### 처리 UX

1. 플레이어가 조사 페이지 주소를 복사한다. Browser 주소 복사와 일반 붙여넣기를 사용하며 별도 클립보드 시스템은 만들지 않는다.
2. S-LINK에서 주소를 입력하고 해당 페이지의 처리 가능한 내용 단위를 선택한다.
3. 선택 항목과 작업 종류를 확인해 등록한다. 등록은 실행이 아니다.
4. S-LINK가 해당 의뢰의 승인 대상과 작업 종류를 검증한다. 범위 밖이면 상태를 바꾸지 않고 거부한다.
5. 실행 전 대상 주소·내용·처리 결과를 한 화면에서 확인한다. 등록된 항목은 실행 전 제거할 수 있다.
6. 처리 실행 후 원본 JSON이 아니라 SessionState의 해당 target 상태만 갱신한다.
7. 웹으로 돌아가 결과를 확인하고, 모든 필수 처리 후 보고한다.

첫 의뢰의 판단은 '원본/연결 이미지/재업로드를 구분하여 각각 맞는 범위를 처리하는 것'이다. 본문 글자를 직접 타이핑하거나 사진을 드래그 편집하는 노동을 추가하지 않는다.

### 승인 규칙

- 의뢰를 읽고, 실제 표시·확인한 페이지/항목만 등록할 수 있다. 이 확인 기록은 UI가 제공된 사실을 기록할 뿐 사람의 이해를 자동 판정하지 않는다.
- 게시물 본문 전체 삭제, blueframe 계정 삭제, DIARY 삭제는 승인 범위가 아니다.
- 실명 항목에는 redact, 개별 이미지에는 delete_image만 허용한다.
- 같은 항목 중복 등록·중복 처리는 상태를 중복 증가시키지 않는다.
- 재클릭·앱 전환·뒤로 가기로 승인 검사를 우회하지 못한다.
- 잘못된 입력을 처리 성공으로 표시하거나 보고 버튼 활성만으로 완료를 판단하지 않는다.

### 완료 조건

`처리 준비 완료`는 다음 세 결과를 SessionState에서 계산한다.

1. TalkBoard의 지정 실명 블록이 비식별화됨.
2. PicBox 원본 이미지 ID가 삭제됨.
3. MyRoom 재업로드 이미지 ID가 삭제됨.

`의뢰 완료`는 위 세 조건 + 플레이어의 완료 보고 성공이다. 둘을 구분한다.

- 방문 페이지 수·단서 수·검색 횟수·진행 시간으로 완료시키지 않는다.
- MyRoom DIARY는 없어도 완료 가능하다.
- 미발견 복사본이 남은 상태에서 보고하면 '재업로드 확인과 처리가 완료되지 않음' 정도의 의뢰 범위 안내만 준다. 정답 URL은 주지 않는다.
- 완료 답신은 1회만 추가한다.
- 썸네일 연출의 관찰 여부는 업무 완료 조건이 아니다. Prototype 검증 항목으로 별도 확인한다.

## 11. SessionState와 진행 수명

| 상태 | 의미 |
|---|---|
| mission_read | 첫 의뢰를 열어 확인했는지 |
| visited_page_ids | 실제 연 페이지 집합 |
| observed_content_ids | 화면에 표시/확인한 처리 항목 집합 |
| registered_target_ids | 현재 등록된 대상 집합 |
| processed_actions | target_id → 적용된 승인 작업 |
| reported | 모든 필수 처리 후 보고했는지 |
| cache_event_status | idle / armed / showing / finished |

처리 준비 여부·본문 비식별 여부·이미지 삭제 여부·답신 표시 여부는 위 상태와 mission 데이터에서 파생한다. `is_done`, `remaining_count`, `image_deleted` 같은 중복 상태를 여러 화면에 따로 저장하지 않는다.

Browser의 주소·질의·기록·스크롤은 Browser가 소유하는 UI 상태다. SessionState와 혼합하지 않는다.

앱을 오갈 때 두 상태가 유지된다. 재시작은 Main과 상태 객체를 새로 생성하는 초기화로 충분하다. 저장 파일은 만들지 않는다. 사용자의 실제 PC 파일·브라우저 기록·계정을 읽거나 삭제하지 않는다.

## 12. 작은 공포 이벤트

- 종류는 ch01 삭제 썸네일 재등장 한 개뿐이다. 범용 이벤트 Resource·DSL·타임라인 시스템은 없다.
- 두 필수 이미지 처리가 끝나면 armed. 실제 삭제 직후 사용자가 볼 다음 관련 FindOn 결과에 연결한다.
- 해당 검색 결과가 표시될 때 showing으로 전환하고, 원본 썸네일을 약 0.6~1.0초 동안만 표시한다. 정확한 시간은 테스트 조정값이다.
- 별도 사운드, 화면 전체 글리치, 기업 경고 문구는 없다.
- 썸네일은 UI 임시 override다. 처리 상태와 JSON은 변경하지 않는다.
- 클릭해서 이동하면 원본은 삭제 상태다.
- 노출 전에 다른 화면을 보면 armed 상태를 유지한다. 노출 중 화면을 떠나면 연출을 종료하고 finished로 처리한다.
- 타이머 종료 콜백은 현재 화면 인스턴스/route가 아직 유효한지 확인한다. 해제된 Control을 건드리지 않는다.
- 재검색·앞뒤 이동으로 반복 재생되지 않는다. 새 세션에서만 다시 시작한다.

## 13. 콘텐츠 추가 절차

### 기존 형태의 새 페이지

1. JSON pages에 고유 page_id·route와 블록을 추가한다.
2. 기존 페이지 링크 또는 검색 필드로 접근 경로를 연결한다.
3. 필요한 이미지를 images에 등록한다. 기존 이미지의 참조와 별도 복사본을 구분한다.
4. 처리 대상이면 mission.required_targets에 정확한 내용 ID와 작업을 연결한다.
5. 플레이 경로와 데이터 검증을 실행한다.

기존 블록 조합이면 `.gd`와 `.tscn` 수정 없이 추가되어야 한다. 새 사이트도 현재 블록으로 표현 가능하면 sites의 표시 정보와 페이지 데이터만 추가한다. 새로운 상호작용 자체가 필요할 때만 별도 설계 후 코드를 수정한다. 모든 미래 사이트를 데이터만으로 표현하겠다는 목표는 두지 않는다.

### 현재 필요한 데이터 검증

- JSON 파싱 오류, 필수 키·타입, 중복 ID/route.
- page/site/image/link/target/mail 참조 누락.
- 등록 대상의 위치와 action 유형 불일치.
- 재업로드가 원본과 같은 상태 ID를 사용하는 오류.
- 없는 에셋 경로, 지원하지 않는 블록 종류.
- 오류에는 파일·구역·ID를 표시한다. 범용 스키마 엔진이나 콘텐츠 편집기는 만들지 않는다.

Windows export에서는 원시 JSON이 누락되지 않도록 비리소스 export 포함 설정을 확인한다. JSON 문자열로만 참조되는 이미지도 배포에 포함해야 한다. 이 작은 Prototype은 전체 리소스 포함 export가 단순하다. 에디터 실행 성공과 export 실행 성공은 별도로 확인한다.

## 14. 검증과 구현 완료의 구분

- M1~M5의 실제 작업 순서는 ROADMAP.md를 따른다.
- 런타임/에디터 실행이 불가능하면 '문서 또는 정적 확인만 수행'이라고 보고한다.
- 자동 검증은 데이터 참조, 복사본 독립성, 조기 완료·중복 처리·잘못된 작업 거부처럼 구체적인 위험에 한정한다.
- 재미·단서 인지·가독성·공포는 직접 플레이로 확인한다. 자동 테스트 성공을 재미의 증거로 제시하지 않는다.

### 최종 구조 점검

| 우려 | 제거·제한한 설계 |
|---|---|
| 첫 Prototype에 시스템이 많음 | 6개 서비스 이름을 공통 웹 화면+검색+메일+업무 UI로 구현, 별도 웹앱 없음 |
| 과도한 추상화 | Autoload 0, Manager 0, 커스텀 Resource 0, 범용 규칙 언어 0 |
| 콘텐츠 추가마다 코드 수정 | 페이지/블록/검색/대상은 JSON, 동작 추가만 코드 변경 |
| UI와 콘텐츠 결합 | 본문·원문·대상 ID는 JSON, 레이아웃은 View, 변화는 SessionState |
| 대형 Main Script | Main은 연결과 수명만 소유, 검색·승인·렌더링은 각각 분리 |
| 미래 기능 선구현 | 다음 Chapter·Messenger·Steam·세이브·창 관리·완성형 옵션 제외 |
| 데이터 구조가 과도함 | 첫 의뢰 JSON 한 파일과 고정 블록 5종, CMS 없음 |

## 15. 기술 참고

Godot 공식 문서의 기능을 바탕으로 한 프로젝트별 설계이며, 공식 문서가 이 게임의 아키텍처를 정해 주는 것은 아니다. 실제 구현 시 선택한 Godot 버전의 문서로 API를 확인한다.

- [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html): Autoload의 수명과 역할. 본 Prototype은 Main 수명으로 충분해 사용하지 않음.
- [BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html): 텍스트 표시·링크 입력. 링크 처리는 게임 내부 route로 제한.
- [FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html): 파일 읽기와 export 시 원시 파일 포함 주의.
- [JSON](https://docs.godotengine.org/en/stable/classes/class_json.html): JSON 로딩·오류 확인.
