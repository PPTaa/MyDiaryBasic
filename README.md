#  MyDiaryBasic App

### 사용기술

- UITabBarController
- UICollectionView
- NotificationCenter

### Priority 관련

- Hugging Priority - 이렇게 공간이 남을 때 무엇이 커질 지 설정해주는 것

> 우선순위가 높으면 내 크기 유지. 우선순위 낮으면 크기 늘어남 (늘어난다 = 당겨진다 = 커진다)

- Compression resistance priority - 공간이 부족할 때 무엇이 줄어들지 설정해주는 것.

> 우선순위가 높으면 내 크기 유지. 우선순위 낮으면 크기 작아짐 (밀린다 = 찌그러진다 = 작아진다) 

두 오브젝트 중 하나가 커져야하는 상황 -> Hugging priority 쓰고 

두 오브젝트 중 하나가 작아져야하는 상황 -> Resistance priority 쓴다 

![image](./capture.png)
