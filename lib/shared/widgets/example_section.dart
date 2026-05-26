import 'package:flutter/material.dart';
import '../data/tutorial_data.dart';

class ExampleSection extends StatelessWidget {
  final String tutorialKey;
  final Function(String, String?)? onExampleSelected;

  const ExampleSection({
    Key? key,
    required this.tutorialKey,
    this.onExampleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final guide = TutorialData.guides[tutorialKey];
    if (guide == null || guide.examples.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '📚 Contoh Penggunaan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () => _showAllExamples(context, guide),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: guide.examples.length,
              itemBuilder: (context, index) {
                final example = guide.examples[index];
                return _buildExampleChip(context, example, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(
      BuildContext context, Example example, int index) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          onExampleSelected?.call(example.value1, example.value2);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${example.title} dipilih'),
              duration: Duration(milliseconds: 1500),
              backgroundColor: Colors.green.shade600,
            ),
          );
        },
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
              ),
            ],
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                example.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.amber.shade900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Expanded(
                child: Text(
                  example.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '✓ Coba',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllExamples(BuildContext context, TutorialGuide guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📚 ${guide.examples.length} Contoh Penggunaan'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: guide.examples.length,
            itemBuilder: (context, index) {
              final ex = guide.examples[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        ex.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Input: ${ex.value1}${ex.value2 != null ? ' + ${ex.value2}' : ''}',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '→ ${ex.result}',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
