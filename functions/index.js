const functions = require("firebase-functions");
const vision = require("@google-cloud/vision");
const cors = require("cors")({ origin: true });
const express = require("express");
const axios = require("axios");

const app = express();
app.use(cors);
app.use(express.json());

// Google Vision 클라이언트 초기화
const client = new vision.ImageAnnotatorClient();

// POST /label-image
app.post("/label-image", async (req, res) => {
  try {
    const imageUrl = req.body.imageUrl;
    if (!imageUrl) return res.status(400).send("Missing imageUrl");

    // ✅ 이미지 다운로드
    const imageResponse = await axios.get(imageUrl, {
      responseType: "arraybuffer",
    });

    const imageBuffer = Buffer.from(imageResponse.data, "binary");

    // ✅ Vision API 호출 - base64 인코딩 후 content로 전달
    const [result] = await client.labelDetection({
      image: {
        content: imageBuffer.toString("base64"),
      },
    });

    const labels = result.labelAnnotations.map(label => label.description);
    console.log("🎯 라벨링 결과:", labels);

    res.status(200).json({ labels });
  } catch (error) {
    console.error("🔥 라벨링 실패:", error);
    res.status(500).send("Vision API Error");
  }
});

// Cloud Function으로 export
exports.labelImage = functions.https.onRequest(app);
