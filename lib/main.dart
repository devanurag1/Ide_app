import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart' as dart;
import 'package:highlight/languages/java.dart' as java;
import 'package:highlight/languages/cpp.dart' as cpp;
import 'package:highlight/languages/python.dart' as python;
import 'package:highlight/languages/javascript.dart' as javascript;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CodeEditor(),
  ));
}

class CodeEditor extends StatefulWidget {
  const CodeEditor({Key? key}) : super(key: key);

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  CodeController? _codeController;
  String selectedLanguage = 'Dart';
  final Map<String, dynamic> languages = {
    'Dart': {
      'highlighter': dart.dart,
      'sampleCode': 'void main() {\n    print("Hello, Dart!");\n}'
    },
    'Java': {
      'highlighter': java.java,
      'sampleCode':
          'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, Java!");\n    }\n}'
    },
    'C++': {
      'highlighter': cpp.cpp,
      'sampleCode':
          '#include <iostream>\nint main() {\n    std::cout << "Hello, C++!";\n    return 0;\n}'
    },
    'Python': {
      'highlighter': python.python,
      'sampleCode': 'def main():\n    print("Hello, Python!")\n\nmain()'
    },
    'JavaScript': {
      'highlighter': javascript.javascript,
      'sampleCode':
          'function main() {\n    console.log("Hello, JavaScript!");\n}\nmain();'
    }
  };

  @override
  void initState() {
    super.initState();
    _initializeCodeController(selectedLanguage);
    _loadSavedCode(); // Load previously saved code state
  }

  void _initializeCodeController(String language) {
    _codeController?.dispose();

    final languageConfig = languages[language];
    _codeController = CodeController(
      text: languageConfig['sampleCode'],
      language: languageConfig['highlighter'],
    );

    setState(() {});
  }

  Future<void> _loadSavedCode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(selectedLanguage) ??
        languages[selectedLanguage]['sampleCode'];
    setState(() {
      _codeController!.text = savedCode;
    });
  }

  Future<void> _saveCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedLanguage, _codeController!.text);
  }

  // Basic error detection (unmatched braces)
  void _checkForErrors() {
    final code = _codeController?.text ?? '';
    if (!_isBracesBalanced(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Syntax Error: Unmatched braces detected!")),
      );
    }
  }

  bool _isBracesBalanced(String code) {
    int balance = 0;
    for (var char in code.runes) {
      if (char == '{'.codeUnitAt(0)) balance++;
      if (char == '}'.codeUnitAt(0)) balance--;
      if (balance < 0) return false;
    }
    return balance == 0;
  }

  @override
  void dispose() {
    _saveCode(); // Save code on exit
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Editor'),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.amber,
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            dropdownColor: Colors.amber,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            onChanged: (String? newLanguage) {
              if (newLanguage != null && newLanguage != selectedLanguage) {
                selectedLanguage = newLanguage;
                _initializeCodeController(newLanguage);
              }
            },
            items:
                languages.keys.map<DropdownMenuItem<String>>((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child:
                    Text(language, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _checkForErrors,
            tooltip: 'Check for Syntax Errors',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _codeController != null
              ? CodeField(
                  controller: _codeController!,
                  textStyle: const TextStyle(fontFamily: 'SourceCodePro'),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
