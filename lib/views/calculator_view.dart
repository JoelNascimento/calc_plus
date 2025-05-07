import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/calculation.dart';
import 'history_view.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final TextEditingController _controller = TextEditingController();
  String result = '';
  void _insertText(String text) {
    setState(() {
      _controller.text += text;
    });
  }

  void _clear() {
    setState(() {
      _controller.clear();
    });
  }

  void _deleteLast() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _controller.text = _controller.text.substring(
          0,
          _controller.text.length - 1,
        );
      }
    });
  }

  Future<void> _solveExpression() async {
    String userInput = _controller.text;

    try {
      // Substitui símbolos se necessário
      userInput = userInput
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('√', 'sqrt');

      Parser p = Parser();
      Expression exp = p.parse(userInput);
      ContextModel cm = ContextModel();

      double eval = exp.evaluate(EvaluationType.REAL, cm);


      setState(() {
        result = eval.toString();
      });
      // Exibe o resultado
      /*showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Resultado"),
              content: Text("$userInput = $result"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );*/
      var historyBox = Hive.box<Calculation>('history');
      var calc = Calculation(expression: userInput, result: result);
      await historyBox.add(calc);
    } catch (e) {
      // Em caso de erro na expressão
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Erro"),
              content: const Text("Expressão inválida."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  Widget _buildButton(String label, {VoidCallback? onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap ?? () => _insertText(label),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  void _exportHistory() async {

    var historyBox = Hive.box<Calculation>('history');
    //var calc = Calculation(expression: userInput, result: result);
    //await historyBox.add(calc);

    //final box = Hive.box('history');
    if (historyBox.isEmpty) return;

    final content = historyBox.values
        .map((e) => "${historyBox.values}")
        .join('\n');
    final file = await File(
      '${(await getTemporaryDirectory()).path}/history.txt',
    ).writeAsString(content);
    Share.shareXFiles([XFile(file.path)], text: 'Histórico SmartCalc');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final tecladoHeight = screenHeight * 0.7;
    final expressaoHeight = screenHeight * 0.08;
    final resultadoHeight = screenHeight * 0.08;

    final buttons = [
      '(',
      ')',
      '^',
      '√',
      '7',
      '8',
      '9',
      '/',
      '4',
      '5',
      '6',
      '*',
      '1',
      '2',
      '3',
      '-',
      '0',
      '.',
      '=',
      '+',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calc+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryView()),
              );
            },
          ),
          /*IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              // Exibe diálogo de seleção de tema
              _showThemeDialog(context);
            },
          ),*/
          //IconButton(icon: const Icon(Icons.share), onPressed: _exportHistory),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: expressaoHeight,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerRight,
                    child: TextField(
                      controller: _controller,
                      readOnly: true,
                      style: const TextStyle(fontSize: 28),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ),
                SizedBox(
                  height: resultadoHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        result,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: tecladoHeight,
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(8),
              children:
                  buttons.map((label) {
                      if (label == '=') {
                        return _buildButton(
                          label,
                          onTap: _solveExpression,
                          color: Colors.green[300],
                        );
                      } else {
                        return _buildButton(label);
                      }
                    }).toList()
                    ..addAll([
                      _buildButton(
                        "⌫",
                        onTap: _deleteLast,
                        color: Colors.orange[200],
                      ),
                      _buildButton("C", onTap: _clear, color: Colors.red[200]),
                    ]),
            ),
          ),
        ],
      ),
    );
  }
}

/*
import 'dart:io';

import 'package:calc_plus/controlers/hive.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/calculation.dart';
import 'history_view.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  String _expression = '';
  String _result = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _onPressed(String value) {
    setState(() {
      if (value == '=') {
        _calculateResult();
      } else {
        _expression += value;
      }
    });
  }

  Future<void> _calculateResult() async {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression.replaceAll('×', '*').replaceAll('÷', '/'));
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _result = eval.toString();
      // Após calcular


    } catch (e) {
      _result = 'Erro';
    }
    var historyBox = Hive.box<Calculation>('history');
    var calc = Calculation(expression: _expression, result: _result);
    await historyBox.add(calc);
  }

  void _onClear() {
    setState(() {
      _expression = '';
      _result = '';
    });
  }

  void _exportHistory() async {
    final box = Hive.box('history');
    if (box.isEmpty) return;

    final content = box.values.map((e) => "${e['expression']} = ${e['result']}").join('\n');
    final file = await File('${(await getTemporaryDirectory()).path}/history.txt').writeAsString(content);
    Share.shareXFiles([XFile(file.path)], text: 'Histórico SmartCalc');
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Claro'),
              onTap: () {
                // usar Provider ou ValueNotifier
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Escuro'),
              onTap: () {
                // atualizar tema
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _expression += val.recognizedWords.replaceAll('x', '*');
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCalc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryView()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              // Exibe diálogo de seleção de tema
              _showThemeDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportHistory,
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: _startVoiceInput, // Requer speech_to_text
          ),
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(_expression, style: const TextStyle(fontSize: 24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(_result, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ),
          ),
          Wrap(
            children: [
              '7', '8', '9', '÷',
              '4', '5', '6', '×',
              '1', '2', '3', '-',
              '0', '.', '=', '+',
            ].map((e) {
              return SizedBox(
                width: 90,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _onPressed(e),
                  child: Text(e, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
          TextButton(onPressed: _onClear, child: const Text("Limpar"))
        ],
      ),
    );
  }
}
*/

