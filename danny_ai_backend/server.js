import express from "express";
import multer from "multer";
import cors from "cors";
import fs from "fs";

const app = express();
const upload = multer({ dest: "uploads/" });

app.use(cors());
app.use(express.json());

// Simple dark-mode upload page
app.get("/upload", (req, res) => {
    const license = req.query.license || "unknown";

    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>2ndHomeRP – AI Emote Creator</title>
            <style>
                body {
                    background-color: #050505;
                    color: #f5f5f5;
                    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                }
                .panel {
                    background: #111;
                    border: 1px solid rgba(255, 215, 0, 0.5);
                    padding: 24px 28px;
                    border-radius: 14px;
                    width: 360px;
                    max-width: 90%;
                    text-align: center;
                    box-shadow: 0 0 30px rgba(0,0,0,0.8);
                }
                h1 {
                    font-family: "Old English Text MT", "Times New Roman", serif;
                    color: #ffd700;
                    font-size: 22px;
                    margin-bottom: 6px;
                }
                h2 {
                    font-size: 12px;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                    color: #ccc;
                    margin-bottom: 18px;
                }
                p {
                    font-size: 13px;
                    margin-bottom: 8px;
                    color: #ddd;
                }
                .hint {
                    font-size: 11px;
                    color: #888;
                    margin-bottom: 16px;
                }
                input[type="file"] {
                    margin-bottom: 14px;
                }
                button {
                    background: #ffd700;
                    color: #111;
                    border: none;
                    border-radius: 999px;
                    padding: 8px 20px;
                    font-weight: 600;
                    cursor: pointer;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }
            </style>
        </head>
        <body>
            <div class="panel">
                <h1>2ndHomeRP – AI Emote Creator</h1>
                <h2>Powered by DeepMotion</h2>

                <p>License ID:</p>
                <p class="hint">${license}</p>

                <p>Select a video file showing your full body performing the emote.</p>
                <p class="hint">Good lighting • No big moving background • One person in frame.</p>

                <form action="/upload" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="license" value="${license}" />
                    <input type="file" name="video" accept="video/*" required /><br/>
                    <button type="submit">Upload Video</button>
                </form>
            </div>
        </body>
        </html>
    `);
});

// Handle uploaded video (DeepMotion wiring will go here later)
app.post("/upload", upload.single("video"), async (req, res) => {
    const license = req.body.license || "unknown";
    const filePath = req.file?.path;

    console.log("New upload from", license, "file:", filePath);

    // For now: just simulate success and say "emote will appear soon"
    // Later: here we call DeepMotion, convert the animation, and notify FiveM.

    // Example: store basic info
    if (!fs.existsSync("emotes")) fs.mkdirSync("emotes");
    fs.writeFileSync(
        `emotes/${license}_${Date.now()}.json`,
        JSON.stringify({
            license,
            filePath,
            status: "uploaded",
            note: "DeepMotion integration pending"
        }, null, 2)
    );

    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Upload Received</title>
            <style>
                body {
                    background-color: #050505;
                    color: #f5f5f5;
                    font-family: system-ui, sans-serif;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                }
                .panel {
                    background: #111;
                    border: 1px solid rgba(255, 215, 0, 0.5);
                    padding: 24px 28px;
                    border-radius: 14px;
                    width: 360px;
                    max-width: 90%;
                    text-align: center;
                }
                h1 { color: #ffd700; margin-bottom: 10px; }
                p { font-size: 13px; color: #ddd; margin-bottom: 8px; }
            </style>
        </head>
        <body>
            <div class="panel">
                <h1>Upload Received</h1>
                <p>Your video has been uploaded for processing.</p>
                <p>You can return to the game. Once AI processing is added, your emote will appear under "2ndHomeRP AI Emotes".</p>
            </div>
        </body>
        </html>
    `);
});

// Start server
const PORT = process.env.PORT || 8080;
app.listen(PORT, "0.0.0.0", () => {
    console.log("2ndHomeRP AI Backend running on port", PORT);
});
