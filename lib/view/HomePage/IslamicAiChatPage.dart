import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';

class IslamicAiChatPage extends StatefulWidget {
  const IslamicAiChatPage({super.key});

  @override
  State<IslamicAiChatPage> createState() => _IslamicAiChatPageState();
}

class _IslamicAiChatPageState extends State<IslamicAiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "السلام عليكم ورحمة الله وبركاته، أنا رفيقك الرقمي، كيف يمكنني مساعدتك اليوم في ذكر الله؟",
      "isMe": false,
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      // رسالة المستخدم
      _messages.add({
        "text": _messageController.text,
        "isMe": true,
      });
      
      String userText = _messageController.text;
      _messageController.clear();

      // رد البوت "الوهمي" بعد تأخير بسيط ليظهر كأنه يفكر
      Future.delayed(const Duration(milliseconds: 800), () {
        _generateBotResponse(userText);
      });
    });
  }

  void _generateBotResponse(String userText) {
    String response = "بارك الله فيك، هل تود أن أذكرك ببعض الأذكار أو أسماء الله الحسنى؟";

    if (userText.contains("سلام")) {
      response = "وعليكم السلام ورحمة الله وبركاته، أنار الله دربك بالإيمان.";
    } else if (userText.contains("تعبان") || userText.contains("ضيق")) {
      response = "قال تعالى: (أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ). أكثر من قول 'لا حول ولا قوة إلا بالله'.";
    } else if (userText.contains("ذكر") || userText.contains("أذكار")) {
      response = "سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر. هل تود المزيد؟";
    }

    setState(() {
      _messages.add({
        "text": response,
        "isMe": false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        title:  Text('أنيس الروح (AI)', style: TextStyle(color: AppColors.accentGold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg['text'], msg['isMe']);
              },
            ),
          ),

          // حقل إدخال الرسالة
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.accentGold : AppColors.secondaryDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? Radius.zero : const Radius.circular(15),
            bottomRight: isMe ? const Radius.circular(15) : Radius.zero,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? AppColors.primaryDark : AppColors.textWhite,
            fontSize: 15,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: AppColors.secondaryDark,
      child: Row(
        children: [
          IconButton(
            icon:  Icon(Icons.send, color: AppColors.accentGold),
            onPressed: _sendMessage,
          ),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _messageController,
                style:  TextStyle(color:  AppColors.textWhite),
                decoration: InputDecoration(
                  hintText: "اسألني شيئاً...",
                  hintStyle:  TextStyle(color:  AppColors.textWhite),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}