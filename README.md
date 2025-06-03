# 🎁 Giftoyou - 소셜미디어 기반 AI 선물 추천 앱

<img src="https://github.com/user-attachments/assets/ccb01c4f-83f7-40d8-b147-e6295430225a" width=200 height=430> &nbsp;
<img src="https://github.com/user-attachments/assets/dc8d7e8e-67a9-4140-8144-9a26f52c672d" width=200 height=430> &nbsp;
<img src="https://github.com/user-attachments/assets/4e11279a-ba56-4589-aff9-be03f3bf3ab8" width=200 height=430> &nbsp;
<img src="https://github.com/user-attachments/assets/9ff246f3-e2c1-4c68-8b6a-da9c9143edc3" width=200 height=430> &nbsp;
<!-- <img src="https://github.com/user-attachments/assets/302beb10-670e-48d9-a71e-a09bc29f58fb" width=200 height=430> -->

**Giftoyou**는 친구의 소셜미디어 데이터를 분석해 AI가 맞춤형 선물을 추천해주는 감성 기반 선물 추천 서비스입니다.  
소셜미디어 활동을 기반으로 친구의 관심사를 파악하고, 온라인 쇼핑 연동까지 가능한 스마트한 선물 큐레이션 앱입니다.

---

## ✨ 주요 기능

### ✅ 1. 친구의 소셜미디어 분석 → 관심사 파악
- 인스타그램, 트위터, 페이스북, 블로그, 틱톡 등 다양한 SNS 분석
- 게시물, 좋아요, 댓글을 통해 관심 키워드 추출
- 예시: `"캠핑"` 관련 포스팅이 많다면 → 캠핑 용품 추천

### ✅ 2. AI 선물 추천 알고리즘
- AI가 친구의 관심사/취향에 맞는 선물 카테고리 자동 제안
- 실시간 트렌드 반영
- 예시: `"커피"` 관련 활동 많다면 → 스페셜티 원두 추천

### ✅ 3. 온라인 쇼핑몰 연동
- 쿠팡, 네이버 쇼핑, 아마존 등과 연동하여 바로 구매 가능
- 가격 비교 기능 제공

### ✅ 4. 이벤트 & 기념일 자동 알림
- 친구 생일 및 기념일을 자동 인식
- 예시: `"이번 주 생일"` → 미리 선물 추천

### ✅ 5. 직접 입력 기능
- SNS 외에도 친구의 취향 직접 입력 가능
- 예시: `"보드게임을 좋아함"` → 관련 선물 추천

---

## 🚀 기술 스택

| 구성 요소         | 기술 |
|------------------|------|
| SNS 데이터 분석   | Google Vision API, Selenium, BeautifulSoup |
| NLP 및 키워드 분석 | Python, Gemini(Google) |
| 추천 시스템       | 협업 필터링, 콘텐츠 기반 필터링 |
| 쇼핑몰 연동       | 쿠팡 / 네이버 / 아마존 / 11번가 API |
| 백엔드            | Firebase, Flask, Node.js (선택적) |
| 프론트엔드        | Flutter (iOS / Android 지원) |
| 푸시 알림         | Firebase Cloud Messaging (FCM) |

---

## 🎯 차별화 포인트

✔ **단순 인기상품이 아닌, 친구의 SNS 관심사 기반 맞춤 추천**  
✔ **기념일 알림과 최신 트렌드를 반영한 실시간 추천**  
✔ **선물 가격 비교 + 구매 연동까지 원스톱 지원**  
✔ **실제 데이터를 활용한 ‘진짜 AI 선물 큐레이션’ 시스템**

---

## 🎬 사용 시나리오

1. 친구의 SNS 계정 연동 or URL 입력
2. AI가 게시물 및 활동 데이터를 분석하여 관심사 도출
3. 맞춤형 선물 카테고리/상품 추천
4. 가격 비교 → 바로 쇼핑몰에서 구매
5. 생일/기념일 자동 알림으로 미리 선물 준비


---

## 💡 FAQ 섹션

### ❓ 자주 묻는 질문 (FAQ)

**Q. 친구의 SNS 계정이 비공개일 때도 분석 가능한가요?**  
A. 아닙니다. 계정이 공개되어 있거나 연동 동의가 있는 경우에만 분석 가능합니다.

**Q. 선물 추천 결과는 매일 바뀌나요?**  
A. 트렌드와 친구 활동 내역이 변동되면 추천도 달라집니다.





