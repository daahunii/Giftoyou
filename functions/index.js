const functions = require("firebase-functions");
const vision = require("@google-cloud/vision");
const cors = require("cors")({ origin: true });
const express = require("express");
const axios = require("axios");
const path = require("path");

const app = express();
app.use(cors);
app.use(express.json());

// ✅ Vision API 클라이언트 초기화
const client = new vision.ImageAnnotatorClient({
  keyFilename: path.join(__dirname, "giftoyou-ad070-391002e66d07.json"),
});

// ✅ 라벨링: 루트 경로에서 직접 처리
app.post("/", async (req, res) => {
  try {
    const imageUrls = req.body.imageUrls;
    if (!Array.isArray(imageUrls) || imageUrls.length === 0) {
      return res.status(400).send("Missing or invalid imageUrls");
    }

    const allLabels = new Set();

    for (const imageUrl of imageUrls) {
      const imageResponse = await axios.get(imageUrl, {
        responseType: "arraybuffer",
      });

      const imageBuffer = Buffer.from(imageResponse.data, "binary");

      const [result] = await client.labelDetection({
        image: {
          content: imageBuffer.toString("base64"),
        },
      });

      const labels = result.labelAnnotations?.map(label => label.description) || [];
      labels.forEach(label => allLabels.add(label));
    }

    const uniqueLabels = Array.from(allLabels);
    console.log("🎯 전체 라벨링 결과:", uniqueLabels);

    res.status(200).json({ labels: uniqueLabels });
  } catch (error) {
    console.error("🔥 라벨링 실패:", error);
    res.status(500).send("Vision API Error");
  }
});

// ✅ Cloud Function export
exports.labelImage = functions.https.onRequest(app);