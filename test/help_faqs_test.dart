import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/services/help_faqs.dart';

void main() {
  test('there are five questions, one for each topic', () {
    expect(helpFaqs.length, 5);

    final questions = helpFaqs.map((faq) => faq.question.toLowerCase()).toList();
    expect(questions[0], contains('add')); // adding an expense or income
    expect(questions[1], contains('history')); // viewing transaction history
    expect(questions[2], contains('summary')); // understanding spending summaries
    expect(questions[3], contains('budget')); // setting weekly/monthly budgets
    expect(questions[4], contains('alert')); // understanding budget alerts
  });

  test('every question ends with a question mark and has a real answer', () {
    for (final faq in helpFaqs) {
      expect(faq.question.trim().endsWith('?'), isTrue, reason: faq.question);
      expect(faq.answer.trim().length, greaterThan(80), reason: faq.question);
    }
  });

  test('every question is different', () {
    final questions = helpFaqs.map((faq) => faq.question).toSet();
    expect(questions.length, helpFaqs.length);
  });

  test('no email address, phone link, or web address was invented', () {
    for (final faq in helpFaqs) {
      for (final text in [faq.question, faq.answer]) {
        expect(text.contains('@'), isFalse, reason: text);
        expect(text.toLowerCase().contains('http'), isFalse, reason: text);
        expect(text.toLowerCase().contains('www.'), isFalse, reason: text);
      }
    }
  });

  // These check that the answers stay HONEST about what the app does today.
  // When budgets are saved, alerts are sent, or transactions are stored for
  // good, update the answers AND these checks together.
  test('the answers are honest about the early version', () {
    expect(helpFaqs[0].answer, contains('only kept while the app is open'));
    expect(helpFaqs[3].answer, contains('preview'));
    expect(helpFaqs[3].answer, contains('not saved yet'));
    expect(helpFaqs[4].answer, contains('No notifications are sent yet'));
  });
}
