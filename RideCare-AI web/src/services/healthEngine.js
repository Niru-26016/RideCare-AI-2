import OpenAI from 'openai';

const openai = new OpenAI({
    apiKey: import.meta.env.VITE_OPENAI_API_KEY,
    dangerouslyAllowBrowser: true // For hackathon purposes
});

export const evaluateHealth = (data) => {
    let score = 100;
    let issues = [];

    // 1. Engine Temperature (Normal: 60-90°C)
    if (data.temperature > 105) {
        score -= 25;
        issues.push("Critical Overheating");
    } else if (data.temperature > 95) {
        score -= 10;
        issues.push("Running Hot");
    }

    // 2. Battery Voltage (Normal > 12.2V)
    if (data.voltage < 11.5) {
        score -= 30;
        issues.push("Battery Critically Low");
    } else if (data.voltage < 12.0) {
        score -= 15;
        issues.push("Battery Weak");
    }

    // 3. Servicing (Normal < 5000km since last)
    if (data.mileageSinceService > 8000) {
        score -= 20;
        issues.push("Service Overdue");
    } else if (data.mileageSinceService > 5000) {
        score -= 10;
        issues.push("Service Due Soon");
    }

    // 4. Vibration / Engine knocking (Scaled against baseline since bikes vibrate more than cars naturally)
    const vibrationDiff = data.vibration - (data.baseVib || 10);
    if (vibrationDiff > 25) {
        score -= 20;
        issues.push("Severe Engine Knocking");
    } else if (vibrationDiff > 10) {
        score -= 10;
        issues.push("Abnormal Vibration");
    }

    // 5. Fuel Efficiency 
    const fuelDiff = (data.baseFuel || 20) - data.fuelEfficiency;
    if (fuelDiff > 8) {
        score -= 15;
        issues.push("Poor Fuel Economy");
    } else if (fuelDiff > 4) {
        score -= 5;
        issues.push("Efficiency Dropping");
    }

    // Ensure score stays within bounds
    score = Math.max(0, Math.min(100, score));

    // Determine state
    let state = "Healthy";
    if (score < 40) state = "Critical";
    else if (score < 60) state = "Service Soon";
    else if (score < 80) state = "Attention Needed";

    return { score, state, issues };
};

export const generatePrediction = async (vehicleState) => {
    if (vehicleState.score >= 80) return "Vehicle is operating optimally.";

    try {
        const prompt = `
      You are an AI assistant for "RideCare AI", a vehicle preventative maintenance platform for ride-hailing fleets.
      Analyze this vehicle data and provide a single, short sentence predicting a failure (e.g. "Battery likely to fail within 5 days"). Be direct and concise.
      
      Vehicle Health Score: ${vehicleState.score}/100
      State: ${vehicleState.state}
      Current Issues: ${vehicleState.issues.join(", ")}
    `;

        const response = await openai.chat.completions.create({
            model: "gpt-4-turbo", // Or gpt-3.5-turbo depending on what the key allows
            messages: [{ role: "user", content: prompt }],
            max_tokens: 50,
            temperature: 0.3,
        });

        return response.choices[0].message.content.trim();
    } catch (error) {
        console.error("OpenAI Error:", error);
        return "Unable to generate prediction at this time.";
    }
};
