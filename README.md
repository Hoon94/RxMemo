# 📑 RxMemo

## 📖 목차
1. [소개](#-소개)
2. [시각화된 프로젝트 구조](#-시각화된-프로젝트-구조)
3. [실행 화면](#-실행-화면)
4. [트러블 슈팅](#-트러블-슈팅)
5. [참고 링크](#-참고-링크)

</br>

## 🍀 소개
RxSwift6를 활용하여 기본적인 메모 앱을 구현합니다.

* 주요 개념: `RxSwift`, `RxDatasource`, `Scene Coordinator`

</br>

## 👀 시각화된 프로젝트 구조

```
📦 TwitterTutorial
 ┣ 📂App
 ┣ 📂Scene
 ┣ 📂Service
 ┃ ┣ 📂CoreDataStorage
 ┃ ┗ 📂MemoryStorage
 ┣ 📂Model
 ┣ 📂ViewController
 ┗ 📂ViewModel
```

### 📚 Architecture ∙ Framework ∙ Library

| Category| Name | Tag |
| ---| --- | --- |
| Architecture| MVVM |  |
| Framework| UIKit | UI |
|Library | RxSwift | Data Binding |
| | SnapKit | Layout |

</br>

## 💻 실행 화면 

| 새 메모 | 메모 편집 |
|:--------:|:--------:|
|<img src="https://github.com/user-attachments/assets/6a3978cf-4ae5-434f-9d80-8cfd20ad8fcc" width="300">|<img src="https://github.com/user-attachments/assets/9f2941e8-d1b9-4ec0-a37b-e19361e8edad" width="300">|

| 자동 스크롤 | 메모 삭제 |
|:--------:|:--------:|
|<img src="https://github.com/user-attachments/assets/d73b4bde-c76e-4f76-b328-3c1e8257c5e8" width="300">|<img src="https://github.com/user-attachments/assets/7e7157fb-1e81-489b-8e73-6ae01260a6b2" width="300">|

</br>

## 🧨 트러블 슈팅

1️⃣ **UITableView 데이터 갱신** <br>
-
🔒 **문제점** <br>
- 새 메모를 작성 시 UITableView를 갱신해야 합니다. 하지만 RxSwift를 사용할 때는 reloadData가 동작하지 않습니다.

🔑 **해결방법** <br>
- 이를 위해 TableView를 갱신하기 위해 항상 새로운 이벤트를 전달해야 합니다.

    ```swift
    viewModel.memoList
        .bind(to: tableView.rx.items(cellIdentifier: "cell")) { row, memo, cell in
            var content = cell.defaultContentConfiguration()
            content.text = memo.content
            cell.contentConfiguration = content
        }
        .disposed(by: rx.disposeBag)
    ```
    
    viewModel에 Observable을 사용하여 memoList를 생성하고 새 메모가 추가되면 memoList에 memo를 추가합니다. memoList를 바인딩하여 새 메모에 대한 이벤트가 전달되면 전체 dataSource를 갱신하여 새 메모를 tableView에 표시하도록 합니다.

<br>

2️⃣ **의존성 주입** <br>
-
🔒 **문제점** <br>
- 메모 앱을 구현하는 과정에서 먼저 Memory에 데이터를 저장하고 이후 CoreData를 통해 데이터 모델을 저장하도록 변경하였습니다. 이때 기존에 Memory를 사용하던 모든 부분을 CoreData로 변경해야 하는 문제가 있었습니다.

🔑 **해결방법** <br>
- 이를 해결하기 위해 사용하는 저장소를 주입받도록 수정하였습니다.

    ```swift
    protocol MemoStorageType {
        @discardableResult
        func createMemo(content: String) -> Observable<Memo>

        @discardableResult
        func memoList() -> Observable<[MemoSectionModel]>

        @discardableResult
        func update(memo: Memo, content: String) -> Observable<Memo>

        @discardableResult
        func delete(memo: Memo) -> Observable<Memo>
    }

    class CommonViewModel: NSObject {
        let sceneCoordinator: SceneCoordinatorType
        let storage: MemoStorageType
        
        // ... 생략 ...
    }
    ```
    
    위와 같이 viewModel에서 공통적으로 필요한 부분을 추상화하여 CommonViewModel 클래스를 생성하고 각각의 viewModel에서 이를 상속 받도록 하였습니다. 또한 저장소인 storage는 MemoStorageType Protocol 타입으로 설정하여 필요한 상황에 맞춰 MemoryStorage와 CoreDataStorage를 사용할 수 있도록 의존성을 주입 받고 있습니다.

<br>

3️⃣ **Coordinator Pattern을 통한 화면 전환** <br>
-
🔒 **문제점** <br>
- 화면 전환 역할을 ViewController에서 담당하고 있었습니다. 하지만 이런 경우 현재 ViewController에서 다음으로 실행할 ViewController를 알아야 한다는 점 때문에 높은 결합도를 가질 수 밖에 없었습니다. 또한 프로젝트의 규모가 커질수록 ViewController에서 담당해야 하는 역할이 많아진다는 단점이 있었습니다.

🔑 **해결방법** <br>
- 이를 해결하기 위해 화면 전환 역할을 분리하도록 다음과 같은 과정을 진행하였습니다. 

    - 전환과 관련된 열거형 추가 (TransitionModel.swift)

        ```swift
        enum TransitionStyle {
            case root
            case push
            case modal
        }
        ```
    
    - 앱에서 구현할 scene을 열거형으로 선언 (Scene.swift)

        ```swift
        enum Scene {
            case list(ListViewModel)
            case detail(DetailViewModel)
            case compose(ComposeViewModel)
        }
        ```        

    - Scene과 전환 방식을 매개변수로 받아 다음 Scene으로 전환하는 메서드 추가 (SceneCoordinator.swift)

        ```swift
        protocol SceneCoordinatorType {
            @discardableResult
            func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable

            @discardableResult
            func close(animated: Bool) -> Completable
        }
        ```

    SceneCoordinator는 화면전환을 처리하기 때문에 윈도우 인스턴스와 현재화면에 표시되어 있는 신을 가지고 있어야 합니다.
    
    위와 같이 환면 전환 역할을 SceneCoordinator로 양도하였습니다. 실제로 viewController에서 화면을 전환하는 경우 다음 화면에 필요한 객체를 매개변수로 주입해주는 형태로 화면 전환을 진행할 수 있었습니다.

<br>

4️⃣ **First Responder 설정** <br>
-
🔒 **문제점** <br>
- 메모를 편집하는 화면으로 전환되었을 때 사용자는 메모를 작성하기 위해 UITextView를 터치하여 키보드 입력 모드로 전환해야 합니다. 하지만 사용자 입장에서 메모를 편집하는 화면에 들어섰다는 것은 이미 화면을 편집하고 싶다는 의미이기 때문에 위와 같은 입력 모드로 전환하는 방식은 사용자 경험을 좋지 못하게 하였습니다.

🔑 **해결방법** <br>
- 이를 해결하기 위해 UITextView를 first responder로 변경해 주었습니다.

    ```swift
    class ComposeViewController: UIViewController, ViewModelBindableType {

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            contentTextView.becomeFirstResponder()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if contentTextView.isFirstResponder {
                contentTextView.resignFirstResponder()
            }
        }
        
        // ... 생략 ...
    }
    ```
    
    위와 같이 뷰가 화면에 나타날 때 first responder로 textView를 지정하였습니다. 이렇게 하면 최초 응답자로 textView가 선택되므로 모바일 내의 가상 키보드가 나타나게 됩니다. 사용자는 추가적인 동작 없이 바로 편집할 수 있습니다.


</br>

## 📚 참고 링크
- [🍎Apple Docs: becomeFirstResponder()](https://developer.apple.com/documentation/uikit/uiresponder/becomefirstresponder())
- [📘stackOverflow: How to reload data for a single tableview cell using RXSwift](https://stackoverflow.com/questions/65886289/how-to-reload-data-for-a-single-tableview-cell-using-rxswift)
- [📘blog: Coordinator Pattern](https://zeddios.medium.com/coordinator-pattern-bf4a1bc46930)
- [📘blog: becomeFirstResponder, resignFirstResponder 차이](https://velog.io/@leeinae/becomeFirstResponder-resignFirstResponder-%EC%B0%A8%EC%9D%B4)
</br>

