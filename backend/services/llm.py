import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

# 支持多个 AI Provider，自动回退
def get_client():
    api_key = os.environ.get("LLM_API_KEY", "")
    base_url = os.environ.get("LLM_BASE_URL", "https://api.minimax.chat")

    if not api_key:
        return None

    return OpenAI(api_key=api_key, base_url=base_url)


SYSTEM_PROMPT = """你是"游我"，一个温暖的 AI 记忆陪伴者。

你的特点：
- 说话温柔、真诚，不说教，像朋友一样
- 会记住用户说过的重要事情，但不会刻意强调"我记住了"
- 当用户表达情绪时，先共情，再陪伴
- 偶尔可以用一点点文学性的表达，但不矫情
- 会主动问一些温暖的问题，帮助用户梳理今天

对话会被存储，但只有反复出现、被认可的内容才会成为长期记忆。
你的回复不要太长，一般 2-4 句话为宜。"""


def chat_with_model(message: str, history: list[dict], memory_context: str = None):
    client = get_client()

    if client is None:
        # 无 API Key 时返回温柔的无服务回复
        return "今天先休息吧，改天再继续聊。记住，你值得被好好陪伴。"

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]

    if memory_context:
        messages.append({
            "role": "system",
            "name": "memory",
            "content": f"【长期记忆】{memory_context}"
        })

    # 把历史对话加进来（限制最近 20 条）
    for msg in history[-20:]:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        if role in ("user", "assistant"):
            messages.append({"role": role, "content": content})

    messages.append({"role": "user", "content": message})

    try:
        model = os.environ.get("LLM_MODEL", "MiniMax-Text-01")
        response = client.chat.completions.create(
            model=model,
            messages=messages,
            temperature=0.75,
            max_tokens=500,
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"今天先休息吧，改天再继续聊。记住，你值得被好好陪伴。（服务暂时不可用）"


def generate_memory_note(conversation_summary: str, keywords: list[str]):
    client = get_client()

    if client is None:
        return f"关于「{'、'.join(keywords[:3])}」的这段对话，我记住了。"

    prompt = f"""这是一段对话的摘要：{conversation_summary}
关键词：{', '.join(keywords)}

请用 1-2 句话总结这段对话的核心要点，作为"长期记忆"的沉淀。
要求：温暖、有画面感，像朋友写的日记一样。
只输出记忆句子，不需要其他内容。"""

    try:
        response = client.chat.completions.create(
            model=os.environ.get("LLM_MODEL", "MiniMax-Text-01"),
            messages=[{"role": "user", "content": prompt}],
            temperature=0.6,
            max_tokens=100,
        )
        return response.choices[0].message.content
    except:
        return f"关于「{'、'.join(keywords[:3])}」的这段对话，我记住了。"
