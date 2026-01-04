import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class AIChatbotPage extends StatefulWidget {
  @override
  _AIChatbotPageState createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isTyping = false; // AI typing indicator

  Future<String> sendTochatbot(String userMessage) async {
    const String apiKey = "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";

    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost",
        "X-Title": "Flutter Chatbot",
      },
      body: jsonEncode({
        "model": "mistralai/mistral-7b-instruct","messages": [
          {
            "role": "system",
            "content": """
            You are a customer service chatbot for a beauty and wellness store.
            
            Your job is to answer customer FAQs using ONLY the predefined answers below.
            Do NOT provide additional explanations.
            Do NOT give generic answers.
            Do NOT invent information.
            
            FAQ RULES:
            
            1. If the user asks about services offered or available services:
            Reply:
            "All available services and promotions can be viewed on the Services & Promotions page."
            
            2. If the user asks how to make an appointment or booking:
            Reply:
            "Press the + button and choose your desired date and available time slot."
            
            3. If the user asks about prices or packages:
            Reply:
            "Pricing details can be found on the Services & Promotions page."
            
            4. If the user asks about customer support or how to contact staff:
            Reply:
            "Please go to Contact Us in the Settings section for customer support."
            
            5. If the user asks about session duration or how long a session takes:
            Reply:
            "Sessions typically last between 10 minutes and up to 1 hour."
            
            If the question does NOT match the FAQs above, reply:
            "I'm here to help with questions about our services, bookings, and store information only."
            """
          },
          {
            "role": "user",
            "content": userMessage
          }
        ],
        "temperature": 0.2,
        "max_tokens": 120
      }),
    );

    if (response.statusCode != 200) {
      return " Please try again later.";
    }

    final data = jsonDecode(response.body);
    return data["choices"][0]["message"]["content"];
  }

  // Ready questions
  List<String> quickQuestions = [
    "What are your available services?",
    "How to make an appointment?",
    "What is the price for massage packages?",
    "How to contact customer support?",
    "How long does a session take?"
  ];

  /// Send message + show typing animation
  void sendMessage([String? text]) async {
    final message = text ?? _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": message});
      isTyping = true; // Start typing animation
    });

    if (text == null) {
      _controller.clear();
    }

    scrollToBottom();

    String reply = await sendTochatbot(message);

    setState(() {
      isTyping = false; // Stop typing animation
      messages.add({"sender": "bot", "text": reply.trim()});
    });

    scrollToBottom();
  }

  /// Auto-scroll
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget typingIndicator() {
    return Row(
      children: [
        Image.asset('assets/images/gemini.png', width: 10, height: 10),
        SizedBox(width: 10),
        Text(
          "AI is typing",
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        SizedBox(width: 6),
        AnimatedDots(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("AI Chatbot"),
        centerTitle: true,
        backgroundColor: Color(0xFF91C788),
      ),

      body: Column(
        children: [
          // 🌟 Background intro header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFFD9E8C7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Icon(LucideIcons.messageCircle, size: 34, color: Colors.green.shade700),
                SizedBox(height: 2),
                Text(
                  "Welcome to Chatbot",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                Text(
                  "Ask me anything or choose a question below!",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                SizedBox(height: 2),
              ],
            ),
          ),

          // 🔹 Quick Questions Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: quickQuestions.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => sendMessage(q),
                    child: Container(
                      width: 170,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          q,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom:12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  return typingIndicator();
                }

                final msg = messages[index];
                final isUser = msg["sender"] == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [

                      // Avatar (left side)
                      if (!isUser) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5), //gemini
                          child:Image.asset('assets/images/gemini.png', width: 30, height: 30),
                        ),
                      ],

                      // Chat bubble
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(top:5, bottom: 5),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.green.shade500 :  Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            msg["text"]!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          //Input Box
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 27),
            color: Colors.white70,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  backgroundColor: Color(0xFF358383),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated (...) for typing
class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  _AnimatedDotsState createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<int> dotAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    dotAnimation = IntTween(begin: 0, end: 3).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dotAnimation,
      builder: (context, child) {
        String dots = "." * dotAnimation.value;
        return Text(
          dots,
          style: const TextStyle(fontSize: 18),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


