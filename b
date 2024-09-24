<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>健康管理システム</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        label {
            display: block;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <h1>健康管理システム</h1>

    <form id="healthForm">
        <label for="name">名前:</label>
        <input type="text" id="name" required><br>

        <label for="gender">性別:</label>
        <select id="gender" required>
            <option value="male">男性</option>
            <option value="female">女性</option>
        </select><br>

        <label for="age">年齢:</label>
        <input type="number" id="age" required><br>

        <label for="weight">体重 (kg):</label>
        <input type="number" id="weight" required><br>

        <label for="height">身長 (cm):</label>
        <input type="number" id="height" required><br>

        <label for="activityLevel">活動レベル:</label>
        <select id="activityLevel" required>
            <option value="1.2">座りがちな生活 (運動なし)</option>
            <option value="1.375">軽い運動 (週1-3回)</option>
            <option value="1.55">中程度の運動 (週3-5回)</option>
            <option value="1.725">激しい運動 (週6-7回)</option>
            <option value="1.9">非常に激しい運動 (毎日運動+肉体労働)</option>
        </select><br><br>

        <button type="submit">計算</button>
    </form>

    <h2 id="resultTitle" style="display:none;">結果</h2>
    <div id="result" style="display:none;">
        <p id="bmrResult"></p>
        <p id="dailyCaloriesResult"></p>

        <h3>おすすめレシピ</h3>
        <ul id="recipeList"></ul>

        <h3>個別アドバイス</h3>
        <p id="advice"></p>

        <!-- レシピに関する質問フォーム -->
        <h3>レシピに関する質問</h3>
        <textarea id="recipeQuestion" rows="4" cols="50" placeholder="レシピに関して質問があれば入力してください"></textarea><br>
        <button id="askQuestion">質問する</button>

        <h4>ChatGPTの回答</h4>
        <p id="gptAnswer"></p>
    </div>

    <script>
        const apiKey = 'YOUR_OPENAI_API_KEY'; // ここにOpenAIのAPIキーを入力

        // 簡易レシピデータベース
        const recipes = [
            { name: "サラダチキン", calories: 250 },
            { name: "グリルサーモン", calories: 400 },
            { name: "オートミール", calories: 150 },
            { name: "アボカドトースト", calories: 300 }
        ];

        // BMR計算用関数
        function calculateBMR(gender, weight, height, age) {
            if (gender === 'male') {
                return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
            } else {
                return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
            }
        }

        // レシピ提案の関数
        function suggestRecipes(dailyCalories) {
            const suggestedRecipes = recipes.filter(recipe => recipe.calories <= dailyCalories / 3);
            return suggestedRecipes;
        }

        // ChatGPT API呼び出し関数
        async function getChatGPTResponse(prompt) {
            const response = await fetch("https://api.openai.com/v1/chat/completions", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${apiKey}`
                },
                body: JSON.stringify({
                    model: "gpt-3.5-turbo",
                    messages: [{"role": "user", "content": prompt}],
                    max_tokens: 150
                })
            });

            const data = await response.json();
            return data.choices[0].message.content;
        }

        // フォーム送信時の処理
        document.getElementById('healthForm').addEventListener('submit', async function(event) {
            event.preventDefault(); // フォーム送信を防ぐ

            const name = document.getElementById('name').value;
            const gender = document.getElementById('gender').value;
            const age = parseInt(document.getElementById('age').value);
            const weight = parseFloat(document.getElementById('weight').value);
            const height = parseFloat(document.getElementById('height').value);
            const activityLevel = parseFloat(document.getElementById('activityLevel').value);

            // BMR計算
            const bmr = calculateBMR(gender, weight, height, age);
            const dailyCalories = bmr * activityLevel; // 選択された活動レベルで消費カロリーを計算

            // 結果を表示
            document.getElementById('resultTitle').style.display = 'block';
            document.getElementById('result').style.display = 'block';
            document.getElementById('bmrResult').textContent = `基礎代謝量 (BMR): ${bmr.toFixed(2)} kcal/日`;
            document.getElementById('dailyCaloriesResult').textContent = `1日の推定消費カロリー: ${dailyCalories.toFixed(2)} kcal/日`;

            // レシピの提案
            const recipeList = document.getElementById('recipeList');
            recipeList.innerHTML = ''; // 前回の結果をクリア
            const suggestedRecipes = suggestRecipes(dailyCalories);
            suggestedRecipes.forEach(recipe => {
                const listItem = document.createElement('li');
                listItem.textContent = `${recipe.name} - カロリー: ${recipe.calories} kcal`;
                recipeList.appendChild(listItem);
            });

            // ChatGPTからアドバイスを取得
            const advicePrompt = `${name}さんは${age}歳、性別は${gender === 'male' ? '男性' : '女性'}、体重は${weight}kg、身長は${height}cm、活動レベルは${activityLevel}です。健康に関するアドバイスを提供してください。`;
            const advice = await getChatGPTResponse(advicePrompt);

            // アドバイスの表示
            document.getElementById('advice').textContent = advice;
        });

        // レシピに関する質問の処理
        document.getElementById('askQuestion').addEventListener('click', async function() {
            const question = document.getElementById('recipeQuestion').value;
            const name = document.getElementById('name').value;
            const age = document.getElementById('age').value;
            const weight = document.getElementById('weight').value;
            const height = document.getElementById('height').value;

            // プロンプトを作成してChatGPTに送信
            const questionPrompt = `${name}さんは${age}歳、体重${weight}kg、身長${height}cmです。次のレシピについて質問があります: ${question}`;
            const gptResponse = await getChatGPTResponse(questionPrompt);

            // ChatGPTの回答を表示
            document.getElementById('gptAnswer').textContent = gptResponse;
        });
    </script>
</body>
</html>
