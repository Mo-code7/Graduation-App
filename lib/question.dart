// import 'dart:html';

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'dart:async';

import 'dart:io';
void main() {
  runApp(const Questions());
}

class Questions extends StatelessWidget {
  const Questions({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Questions'),
        ),
        body: const Center(
          child: SmokingQuestions(),
        ),
      ),
    );
  }
}

class SmokingQuestions extends StatefulWidget {
  const SmokingQuestions({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SmokingQuestionsState createState() => _SmokingQuestionsState();
}

class _SmokingQuestionsState extends State<SmokingQuestions> {

  static const String uploadEndPoint='https://lungcancerr2010.pythonanywhere.com';
  static const String uploadEndPointHostginer='https://lungcancerdetection2010.com/Dashboard/storefromhost.php';


  List<XFile> ?file;

  String status = '';
  String base64Image='';

  String errMessage = 'Error Uploading image';
  final TextEditingController _textFieldController = TextEditingController();

  final TextEditingController _textFieldControllerAge = TextEditingController();


  List<int> hostedAttributes = []; // Create an empty list of integers
  List<String> hostedAttributesF = []; // Create an empty list of string

  String _selectedQuestion = 'Questions';
  final Map<String, String> _responses = {};
  List<String> selectedOptions = [];
  List<XFile> _imageFileList = [];
  var fileimg;


  Future<void> takeSingleImage() async {
    List<XFile> images = [];
    for (int i = 0; i <=0 ; i++) {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        images.add(image);
      }
    }

    setState(() {
      _imageFileList = images ??[];
      file = _imageFileList;
    });
  }

  startUpload() {

    List<XFile> files = _imageFileList.map((xfile) => XFile(xfile!.path)).toList();

    for (int value in hostedAttributes) {
      hostedAttributesF.add(value.toString());
    }
    upload(files, hostedAttributesF);
  }


  Future<void> upload(List<XFile> files ,List <String> attributes ) async {
    setStatus('Uploading ....');

    showErrorDialog(context, 'Uploading' ,'Please wait......' , Colors.black45);

    Color recolor = Colors.black45;



    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadEndPoint));

      for (int i = 0; i < files.length; i++) {
        String fileName = files[i].path.split('/').last;
        request.files.add(await http.MultipartFile.fromPath('image$i', files[i].path, filename: fileName));
      }
      //
      List<String> hostValues = List.generate(16, (index) => 'hValue ${index + 1}');
      for(int i=0 ; i<16 ; i++){
        hostValues[i] = attributes[i];

      }

      request.fields['hValues'] = hostValues.join(',');



      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        setStatus('Result: $responseBody');
        var responseBodystore = responseBody.trim();
        // hostValues[17] = responseBodystore.replaceAll('"', '').replaceAll("'", '');

        if(responseBodystore == '"High"'){
          recolor = Colors.red;
        }
        else if(responseBodystore == '"Low"'){
          recolor = Colors.green;
        }
        else if(responseBodystore == '"Medium"'){
          recolor = Colors.yellow;
        }

        // ignore: use_build_context_synchronously
        showErrorDialog(context, 'Result' ,'Your examine result is: $responseBody',recolor);

        // void showErrorDialog(BuildContext context, String responseBody) {
        //   showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         title: const Text('Validation Error'),
        //         content: SingleChildScrollView(
        //           child: ListBody(
        //             children: <Widget>[
        //               Text(
        //                 responseBody,
        //                 style: const TextStyle(color: Colors.red),
        //               ),
        //             ],
        //           ),
        //         ),
        //         actions: <Widget>[
        //           TextButton(
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //             },
        //             child: const Text('OK'),
        //           ),
        //         ],
        //       );
        //     },
        //   );
        // }
        hostValues[16] = responseBody;
        var requestHostinger = http.MultipartRequest('POST', Uri.parse(uploadEndPointHostginer));
        requestHostinger.fields['hValues'] = hostValues.join(',');
        var responseHosinger = await requestHostinger.send();
        if (responseHosinger.statusCode == 200) {
          print('Done from hostinger');
        }

      } else {

        print('Error uploading files. Status code: ${response.statusCode}');
        setStatus('Error uploading files. Status code: ${response.statusCode}');
      }
    } catch (error) {

      print('Error uploading files: $error');
      setStatus('Error uploading files: $error');
    }
    // List<String> validationMessages = [];
    // validationMessages=status as List<String>;
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: const Text('Validation Error'),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: validationMessages
    //             .map((message) => Text(
    //           status,
    //           style: const TextStyle(color: Colors.red),
    //         ))
    //             .toList(),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //           child: const Text('OK'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  void showErrorDialog(BuildContext context,String title, String message , Color mkcolor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: TextStyle(color: mkcolor),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  TextEditingController controllersage = TextEditingController();


  setStatus(String message){
    setState(() {
      status = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children :[SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Center(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Positioned(
                top: 100.0,  // Adjust top padding as needed
                right: 200.0,  // Adjust right padding as needed
                child:Column(
                  children:[
                    Visibility(
                       visible:_selectedQuestion == 'Questions' ? true : false,
                        child:FloatingActionButton(
                          onPressed: () {
                            takeSingleImage();
                          },
                          child: const Icon(Icons.camera_alt),
                        ),
                    ),
                ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _selectedQuestion,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: _selectedQuestion,
                  items: <String>[
                    'Questions',
                    'Smoking',
                    'Passive smoking',
                    'Alcohol usage',
                    'Frequent Cold',
                    'Fatigue',
                    'Shortness of Breath',
                    'Coughing of Blood',
                    'Age',
                    'Swallowing difficulty',
                    'Snoring',
                    'Air Pollution',
                    'Dust Allergy',
                    'Genetic Risk',
                    'Balanced Diet',
                    'Dry Cough'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedQuestion = newValue ?? 'Questions';
                    });
                  },
                ),
              ),
              if (_selectedQuestion == 'Smoking') ...[
                _buildRadioQuestion('How much do you smoke?', [
                  {'text': 'less than 1', 'id': 'smoke1'},
                  {'text': '1', 'id': 'smoke2'},
                  {'text': '2', 'id': 'smoke3'},
                  {'text': '3', 'id': 'smoke4'},
                  {'text': '4', 'id': 'smoke5'},
                  {'text': '5', 'id': 'smoke6'},
                  {'text': 'more than 5', 'id': 'smoke7'},
                ], 'smoke'),
                _buildRadioQuestion('Have you tried quit attempts?', [
                  {'text': 'Yes', 'id': 'Yes1'},
                  {'text': 'No', 'id': 'No1'},
                ],'attempts'),
                _buildRadioQuestion('Do you experience cravings for nicotine?', [
                  {'text': 'Yes', 'id': 'yes2'},
                  {'text': 'No', 'id': 'no2'}
                ],'cravings'),
                _buildRadioQuestion('Do you notice any staining on your fingers or teeth due to smoking?', [
                  {'text': 'Yes', 'id': 'yes3'},
                  {'text': 'No', 'id': 'no3'}
                ],'staining'),
              ],
              if (_selectedQuestion == 'Passive smoking') ...[
                _buildRadioQuestion('Do you spend time around people who smoke?', [
                  {'text': 'Yes', 'id': 'yes4'},
                  {'text': 'No', 'id': 'no4'}
                ],'spend'),
                _buildRadioQuestion('Have you ever been exposed to cigarette smoke in enclosed spaces?', [
                  {'text': 'Yes', 'id': 'yes5'},
                  {'text': 'No', 'id': 'no5'}
                ],'exposed'),
                _buildRadioQuestion('Do you experience symptoms like coughing, headaches, or eye irritation when near smokers?', [
                  {'text': 'Yes', 'id': 'yes6'},
                  {'text': 'No', 'id': 'no6'}
                ],'symptoms'),
                _buildRadioQuestion('	Do you live with someone who smokes?', [
                  {'text': 'Yes', 'id': 'yes7'},
                  {'text': 'No', 'id': 'no7'}
                ],'live'),
              ],
              if (_selectedQuestion == 'Alcohol usage') ...[
                _buildRadioQuestion('How often do you have a drink containing alcohol?', [
                  {'text': 'Never', 'id': 'ans1'},
                  {'text': 'Monthly or less', 'id': 'ans2'},
                  {'text': '2 to 4 times a month', 'id': 'ans3'},
                  {'text': '2 to 3 times a week', 'id': 'ans4'},
                  {'text': '4 or more times a week', 'id': 'ans5'},
                ],'alcohol'),
                _buildRadioQuestion('How many drinks containing alcohol do you have on a typical day when you are drinking?', [
                  {'text': '1 or 2', 'id': 'ans6'},
                  {'text': '3 or 4', 'id': 'ans7'},
                  {'text': '5 or 6', 'id': 'ans8'},
                  {'text': '7 or 9', 'id': 'ans9'},
                  {'text': '10 or more', 'id': 'ans10'},
                ],'typical'),
                _buildRadioQuestion('How often do you have 5 or more drinks on one occasion?', [
                  {'text': 'Never', 'id': 'ans11'},
                  {'text': 'less than monthly ', 'id': 'ans12'},
                  {'text': ' Monthly', 'id': 'ans13'},
                  {'text': 'Weekly', 'id': 'ans14'},
                  {'text': 'Daily or almost daily', 'id': 'ans15'},
                ],'occasion'),
                _buildRadioQuestion('How often during the last year have you found that you were not able to stop drinking once you had started?', [
                  {'text': 'Never', 'id': 'ans16'},
                  {'text': 'Less than monthly', 'id': 'ans17'},
                  {'text': 'Monthly', 'id': 'ans18'},
                  {'text': 'Weekly', 'id': 'ans19'},
                  {'text': 'Daily or almost daily', 'id': 'ans20'},
                ],'stop'),
                _buildRadioQuestion('How often during the last year have you failed to do what was normally expected of you because of drinking?', [
                  {'text': 'Never', 'id': 'ans21'},
                  {'text': 'Less than monthly', 'id': 'ans22'},
                  {'text': 'Monthly', 'id': 'ans23'},
                  {'text': 'Weekly', 'id': 'ans24'},
                  {'text': 'Daily or almost daily', 'id': 'ans25'},
                ],'failed'),
                _buildRadioQuestion('How often during the last year have you needed a first drink in the morning to get yourself going after a heavy drinking session?', [
                  {'text': 'Never', 'id': 'ans26'},
                  {'text': 'Less than monthly', 'id': 'ans27'},
                  {'text': 'Monthly', 'id': 'ans28'},
                  {'text': 'Weekly', 'id': 'ans29'},
                  {'text': 'Daily or almost daily', 'id': 'ans30'},
                ],'needed'),
                _buildRadioQuestion('How often during the last year have you had a feeling of guilt or remorse after drinking?', [
                  {'text': 'Never', 'id': 'ans31'},
                  {'text': 'Less than monthly', 'id': 'ans32'},
                  {'text': 'Monthly', 'id': 'ans33'},
                  {'text': 'Weekly', 'id': 'ans34'},
                  {'text': 'Daily or almost daily', 'id': 'ans35'},
                ],'feeling'),
                _buildRadioQuestion('How often during the last year have you been unable to remember what happened the night before because you had been drinking?', [
                  {'text': 'Never', 'id': 'ans36'},
                  {'text': 'Less than monthly', 'id': 'ans37'},
                  {'text': 'Monthly', 'id': 'ans38'},
                  {'text': 'Weekly', 'id': 'ans39'},
                  {'text': 'Daily or almost daily', 'id': 'ans40'},
                ],'remember'),
                _buildRadioQuestion('Have you or someone else been injured as a result of your drinking?', [
                  {'text': 'No', 'id': 'ans41'},
                  {'text': 'Yes,but not in the last year', 'id': 'ans42'},
                  {'text': 'Yes,during the last year ', 'id': 'ans43'},
                ],'injured'),
                _buildRadioQuestion('Has a relative, a friend, a doctor, or another health worker been concerned about your drinking or suggested you cut down?', [
                  {'text': 'No', 'id': 'ans44'},
                  {'text': 'Yes,but not in the last year', 'id': 'ans45'},
                  {'text': 'Yes,during the last year ', 'id': 'ans46'},
                ],'relative'),
              ],
              if (_selectedQuestion == 'Frequent Cold') ...[
                _buildRadioQuestion('How often do you experience cold symptoms?', [
                  {'text': 'Never', 'id': 'ans47'},
                  {'text': 'Daily', 'id': 'ans48'},
                  {'text': 'Weekly', 'id': 'ans49'},
                  {'text': 'Monthly ', 'id': 'ans50'},
                ],'symptomsfcold'),
                _buildRadioQuestion('How long do your colds typically last?', [
                  {'text': 'Day', 'id': 'ans51'},
                  {'text': 'Week', 'id': 'ans52'},
                  {'text': 'Month', 'id': 'ans53'},
                ],'colds'),
                _buildRadioQuestion('Have you noticed any patterns related to seasons or specific triggers?', [
                  {'text': 'Yes', 'id': 'yes8'},
                  {'text': 'No', 'id': 'no8'},
                ],'triggers'),
                _buildMultipleChoiceQuestion(
                  'What symptoms do you usually experience during a cold? (Multiply Choice)',
                  [
                    {'text': 'Sneezing', 'id': 'ans54'},
                    {'text': 'Coughing', 'id': 'ans55'},
                    {'text': 'Fatigue', 'id': 'ans56'},
                  ],
                  selectedOptions, {
                'frcoldm',
                }
                ),
                _buildRadioQuestion('Do you have nasal congestion, runny nose, sneezing, or sore throat?', [
                  {'text': 'Yes', 'id': 'yes9'},
                  {'text': 'No', 'id': 'no9'},
                ],'nasal'),
                _buildRadioQuestion('Have you had a cough associated with your cold?', [
                  {'text': 'Yes', 'id': 'yes10'},
                  {'text': 'No', 'id': 'no10'},
                ],'cough'),
                _buildRadioQuestion('How severe are your cold symptoms?', [
                  {'text': 'Low', 'id': 'ans57'},
                  {'text': 'Medium', 'id': 'ans58'},
                  {'text': 'High', 'id': 'ans59'},
                ],'severe'),
                _buildRadioQuestion('Do they significantly impact your daily activities?', [
                  {'text': 'Yes', 'id': 'yes11'},
                  {'text': 'No', 'id': 'no11'},
                ],'significantly'),
                _buildRadioQuestion('Have you ever required medical attention for your colds?', [
                  {'text': 'Yes', 'id': 'yes12'},
                  {'text': 'No', 'id': 'no12'},
                ],'medical'),
                _buildRadioQuestion('Do you have any chronic health conditions (e.g., allergies, asthma) that may contribute to frequent colds?', [
                  {'text': 'Yes', 'id': 'yes13'},
                  {'text': 'No', 'id': 'no13'},
                ],'chronic'),
                _buildRadioQuestion('Are you taking any medications that could affect your immune system?', [
                  {'text': 'Yes', 'id': 'yes14'},
                  {'text': 'No', 'id': 'no14'},
                ],'immune'),
                _buildRadioQuestion('Do you receive the flu vaccine regularly?', [
                  {'text': 'Yes', 'id': 'yes15'},
                  {'text': 'No', 'id': 'no15'},
                ],'flu'),
             ],
             if (_selectedQuestion == 'Fatigue') ...[
               _buildRadioQuestion('Do you often feel tired during the day?', [
                 {'text': 'Never', 'id': 'ans60'},
                 {'text': 'Sometimes', 'id': 'ans61'},
                 {'text': 'Often', 'id': 'ans62'},
                 {'text': 'Always ', 'id': 'ans63'},
               ],'fatigue'),
               _buildRadioQuestion('Does your fatigue interfere with your daily activities?', [
                 {'text': 'Not at all', 'id': 'yes16'},
                 {'text': 'A little', 'id': 'no16'},
                 {'text': 'Quite a bit', 'id': 'answer1'},
                 {'text': 'Very much', 'id': 'answer2'},
               ],'fatigued'),
               _buildRadioQuestion('Do you need to rest more than usual?', [
                 {'text': 'Never', 'id': 'ans64'},
                 {'text': 'Sometimes', 'id': 'ans65'},
                 {'text': 'Often', 'id': 'ans66'},
                 {'text': 'Always', 'id': 'answer3'},
               ],'sleep'),
               _buildRadioQuestion('Do you have difficulty concentrating due to fatigue?', [
                 {'text': 'Not at all', 'id': 'ans67'},
                 {'text': 'A little', 'id': 'ans68'},
                 {'text': 'Quite a bit', 'id': 'ans69'},
                 {'text': 'Very much', 'id': 'answer4'},
               ],'lifestyle'),
               _buildRadioQuestion('Does fatigue limit your ability to enjoy life?', [
                 {'text': 'Not at all', 'id': 'answer5'},
                 {'text': 'A little', 'id': 'answer6'},
                 {'text': 'Quite a bit', 'id': 'answer7'},
                 {'text': 'Very much', 'id': 'answer8'},
               ],'ability'),
               _buildRadioQuestion('Do you feel weak or lack energy?', [
                 {'text': 'Never', 'id': 'answer9'},
                 {'text': 'Sometimes', 'id': 'answer10'},
                 {'text': 'Often', 'id': 'answer11'},
                 {'text': 'Always', 'id': 'answer12'},
               ],'energy'),
               _buildRadioQuestion('Does fatigue affect your mood (e.g., make you feel frustrated, irritable, upset)?', [
                 {'text': 'Not at all', 'id': 'answer13'},
                 {'text': 'A little', 'id': 'answer14'},
                 {'text': 'Quite a bit', 'id': 'answer15'},
                 {'text': 'Very much', 'id': 'answer16'},
               ],'mood'),
               _buildRadioQuestion('Do you have difficulty completing tasks due to fatigue?', [
                 {'text': 'Not at all', 'id': 'answer17'},
                 {'text': 'A little', 'id': 'answer18'},
                 {'text': 'Quite a bit', 'id': 'answer19'},
                 {'text': 'Very much', 'id': 'answer20'},
               ],'tasks'),
               _buildRadioQuestion('Does fatigue affect your relationships with other people (e.g., family, friends)?', [
                 {'text': 'Not at all', 'id': 'answer21'},
                 {'text': 'A little', 'id': 'answer22'},
                 {'text': 'Quite a bit', 'id': 'answer23'},
                 {'text': 'Very much', 'id': 'answer24'},
               ],'relationships'),
             ],
              if (_selectedQuestion == 'Shortness of Breath') ...[
                _buildRadioQuestion('Is this deterioration sudden or gradual?', [
                  {'text': 'Sudden', 'id': 'ans70'},
                  {'text': 'Gradual', 'id': 'ans71'},
                ],'deterioration'),
                _buildRadioQuestion('Do you have any chest pain?', [
                  {'text': 'Yes', 'id': 'yes17'},
                  {'text': 'No', 'id': 'no17'},
                ],'chest'),
                _buildRadioQuestion('What is the patient’s oxygen saturation?', [
                  {'text': 'Less than 92%', 'id': 'ans72'},
                  {'text': '95%', 'id': 'ans73'},
                  {'text': '100%', 'id': 'ans74'},
                ],'oxygen'),
              ],
              if (_selectedQuestion == 'Coughing of Blood') ...[
                _buildRadioQuestion('Do you smoke?', [
                  {'text': 'Yes', 'id': 'yes18'},
                  {'text': 'No', 'id': 'no18'},
                ],'Coughing of Blood'),
                _buildRadioQuestion('Do you have chest pain?', [
                  {'text': 'Yes', 'id': 'yes19'},
                  {'text': 'No', 'id': 'no19'},
                ],'pain'),
                _buildRadioQuestion('How long has this been happening?', [
                  {'text': 'Week', 'id': 'ans75'},
                  {'text': 'Month', 'id': 'ans76'},
                  {'text': 'Year', 'id': 'ans77'},
                  {'text': 'More than a Year', 'id': 'ans78'},
                ],'happening'),
                _buildRadioQuestion('Is it a sudden or gradual onset?', [
                  {'text': 'Sudden', 'id': 'ans79'},
                  {'text': 'Gradual', 'id': 'ans80'},
                ],'onset'),
                _buildRadioQuestion('Is it bright red or darker?', [
                  {'text': 'Red', 'id': 'ans81'},
                  {'text': 'Darker', 'id': 'ans82'},
                ],'bright'),
                _buildRadioQuestion('Do you see any clots?', [
                  {'text': 'Yes', 'id': 'ans83'},
                  {'text': 'No', 'id': 'ans84'},
                ],'clots'),
                _buildRadioQuestion('Are you on any medications that may contribute?', [
                  {'text': 'Yes', 'id': 'ans85'},
                  {'text': 'No', 'id': 'ans86'},
                ],'medications'),
              ],

              if (_selectedQuestion == 'Age') ...[

              Padding(
              padding: const EdgeInsets.all(32.0),
              child: TextField(
              controller: _textFieldControllerAge,
              decoration: const InputDecoration(
              labelText: 'Enter Your Age',
              ),
              ),
              ),


              ],
              if (_selectedQuestion == 'Swallowing difficulty') ...[
                _buildRadioQuestion('When did you first notice difficulty with swallowing?', [
                  {'text': 'Day', 'id': 'ans87'},
                  {'text': 'Week', 'id': 'ans88'},
                  {'text': 'Month', 'id': 'ans89'},
                  {'text': 'Year', 'id': 'ans90'},
                  {'text': 'More than a Year', 'id': 'ans91'},
                ],'swallowing'),
                _buildRadioQuestion('Do you get food stuck in your throat?', [
                  {'text': 'Yes', 'id': 'yes20'},
                  {'text': 'No', 'id': 'no20'},
                ],'throat'),
                _buildRadioQuestion('Do you chock while eating?', [
                  {'text': 'Yes', 'id': 'yes21'},
                  {'text': 'No', 'id': 'no21'},
                ],'eating'),
              ],
              if (_selectedQuestion == 'Snoring') ...[
                _buildRadioQuestion('Do you snore?', [
                  {'text': 'Yes', 'id': 'yes22'},
                  {'text': 'No', 'id': 'no22'},
                ],'snore'),
              ],
              if (_selectedQuestion == 'Air Pollution') ...[
                _buildRadioQuestion('Have you lived or worked in any areas with heavy traffic, industrial facilities, or history of poor air quality?', [
                  {'text': 'No', 'id': 'no23'},
                  {'text': 'Maybe', 'id': 'ans92'},
                  {'text': 'Yes', 'id': 'yes23'},
                ],'quality'),
             ],
              if (_selectedQuestion == 'Dust Allergy') ...[
                _buildRadioQuestion('Do you experience any allergy symptoms, such as coughing, wheezing after exposure to dust?', [
                  {'text': 'No', 'id': 'no24'},
                  {'text': 'Maybe', 'id': 'ans93'},
                  {'text': 'Yes', 'id': 'yes24'},
                ],'allergy'),
              ],
              if (_selectedQuestion == 'Genetic Risk') ...[
                _buildRadioQuestion('Do you have any close family members (parents, siblings, children) who have been diagnosed with lung cancer?', [
                  {'text': 'No', 'id': 'no25'},
                  {'text': 'Maybe', 'id': 'ans94'},
                  {'text': 'Yes', 'id': 'yes25'},
                ],'cancer'),
              ],
              if (_selectedQuestion == 'Balanced Diet') ...[
                _buildRadioQuestion('Do you typically follow a specific diet, or are there any foods you avoid for health reasons?', [
                  {'text': 'No', 'id': 'no26'},
                  {'text': 'Maybe', 'id': 'ans95'},
                  {'text': 'Yes', 'id': 'yes26'},
                ],'diet'),
              ],
              if (_selectedQuestion == 'Dry Cough') ...[
                _buildRadioQuestion('Have you noticed any other symptoms along with the cough, such as shortness of breath, or coughing up blood?', [
                  {'text': 'No', 'id': 'no27'},
                  {'text': 'Maybe', 'id': 'ans96'},
                  {'text': 'Yes', 'id': 'yes27'},
                ],'shortness'),
                // MaterialButton(
                //   onPressed: _responses.values.every((value) => value != false) ? _submitAnswers : null,color: Colors.green,
                //   child: const Text('Check',style: TextStyle(color: Colors.white,fontSize: 17),),)
                MaterialButton(
                  onPressed: () {
                    // Check if all values in _responses are true
                    if (_responses.values.every((value) => value == true)) {
                      _submitAnswers(); // Call the desired function
                    } else {
                      // Handle the case where not all values are true (optional)
                      // You can display a message, disable the button, etc.
                      _submitAnswers(); // Call the desired function
                      print('Not all answers are complete!');
                    }
                  },
                  color: Colors.green,
                  child: const Text(
                    'Checking Diseases',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                )

              ],
            ],

          ),

        ),
      ),
    ),
     ],
    );
  }

  Widget _buildRadioQuestion(String question, List<Map<String, String>> options, String responseKey) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18), // Increased font size and added bold
          ),
          const SizedBox(height: 8),
          Column( // Wrap options in a Column to apply padding individually
            children: options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical padding
                child: Row(
                  children: [
                    Radio<String>(
                      value: option['id']!,
                      groupValue: _responses[responseKey],
                      onChanged: (String? value) {
                        setState(() {
                          _responses[responseKey] = value!;
                        });
                      },
                    ),
                    Text(
                      option['text']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Increased font size and added bold
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildMultipleChoiceQuestion(String question, List<Map<String, String>> options, List<String> selectedOptions, Set<String> set) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18), // Increased font size and added bold
          ),
          const SizedBox(height: 8),
          Column( // Wrap options in a Column to apply padding individually
            children: options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical padding
                child: Row(
                  children: [
                    Checkbox(
                      value: selectedOptions.contains(option['id']!),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            selectedOptions.add(option['id']!);
                          } else {
                            selectedOptions.remove(option['id']!);
                          }
                        });
                      },
                    ),
                    Text(
                      option['text']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Increased font size and added bold
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  void _submitAnswers() {
    List<String> validationMessages = [];

    if(file == null){
      validationMessages.add('Clubbing nail image Required');
    }
      else if (_responses['smoke'] == null ||
          _responses['attempts'] == null ||
          _responses['cravings'] == null ||
          _responses['staining'] == null) {
          validationMessages.add('Smoking Required');
      }


      else if (_responses['spend'] == null ||
          _responses['exposed'] == null ||
          _responses['symptoms'] == null ||
          _responses['live'] == null) {
        validationMessages.add('Passive smoking Required ');
      }


      else if (_responses['alcohol'] == null ||
          _responses['typical'] == null ||
          _responses['occasion'] == null ||
          _responses['stop'] == null ||
          _responses['failed'] == null ||
          _responses['needed'] == null ||
          _responses['feeling'] == null ||
          _responses['remember'] == null ||
          _responses['injured'] == null ||
          _responses['relative'] == null)
      {
        validationMessages.add('Alcohol usage Required');
      }


      else if (_responses['symptoms'] == null ||
          _responses['colds'] == null ||
          _responses['triggers'] == null ||
          _responses['nasal'] == null ||
          _responses['cough'] == null ||
          _responses['severe'] == null ||
          _responses['significantly'] == null ||
          _responses['medical'] == null ||
          _responses['chronic'] == null ||
          _responses['immune'] == null ||
          _responses['flu'] == null ||
        selectedOptions.isEmpty
    )
      {
        validationMessages.add('Frequent cold Required');
      }


      else if (_responses['fatigue'] == null ||
          _responses['fatigued'] == null ||
          _responses['sleep'] == null ||
          _responses['lifestyle'] == null )
      {
        validationMessages.add('Fatigue Required');
      }

      else if (_responses['deterioration'] == null ||
          _responses['chest'] == null ||
          _responses['oxygen'] == null )
      {
        validationMessages.add('Shortness of breath Required');
      }


      else if (_responses['Coughing of Blood'] == null ||
          _responses['pain'] == null ||
          _responses['happening'] == null ||
          _responses['onset'] == null ||
          _responses['bright'] == null ||
          _responses['clots'] == null ||
          _responses['medications'] == null)
      {
        validationMessages.add('Coughing of Blood Required');
      }


      else if (_responses['swallowing'] == null ||
          _responses['throat'] == null ||
          _responses['eating'] == null)
      {
        validationMessages.add('Swallowing difficulty Required');
      }


      else if (_responses['snore'] == null )
      {
        validationMessages.add('Snoring Required');
      }

      else if (_responses['quality'] == null)
      {
        validationMessages.add('Air pollution Required');
      }

      else if (_responses['allergy'] == null )
      {
        validationMessages.add('Dust Allergy Required');
      }

      else if (_responses['cancer'] == null )
      {
        validationMessages.add('Genetic Risk Required');
      }

      else if (_responses['diet'] == null )
      {
        validationMessages.add('Balanced diet Required');
      }

      else if (_responses['shortness'] == null )
      {
        validationMessages.add('Dry cough Required');
      }

    if (validationMessages.isNotEmpty) {
      // String? smoke = _responses['smoke']; // Replace with actual question key
      // String? attempts = _responses['attempts']; // Replace with actual question key
      // String? cravings = _responses['cravings']; // Replace with actual question key
      // String? spend = _responses['spend'];
      // String? exposed = _responses['exposed'];
      // String? live = _responses['live'];
      // print(smoke);
      // print(attempts);
      // print(cravings);
      //
      //
      //
      // print(selectedOptions);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Validation Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: validationMessages
                  .map((message) => Text(
                message,
                style: const TextStyle(color: Colors.red),
              ))
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    else if(validationMessages.isEmpty){

      // Smoking part
      String? smoke = _responses['smoke']; // Replace with actual question key
      String? attempts = _responses['attempts']; // Replace with actual question key
      String? cravings = _responses['cravings']; // Replace with actual question key
      String? staining = _responses['staining']; // Replace with actual question key


// passive smoking part
      String? spend = _responses['spend'];
      String? exposed = _responses['exposed'];
      String? live = _responses['live'];
      String? symptoms = _responses['symptoms'];

      // alcohol part
      String? alcohol = _responses['alcohol'];
      String? typical = _responses['typical'];
      String? occasion = _responses['occasion'];
      String? stop = _responses['stop'];
      String? failed = _responses['failed'];
      String? needed = _responses['needed'];
      String? feeling = _responses['feeling'];
      String? remember = _responses['remember'];
      String? injured = _responses['injured'];
      String? relative = _responses['relative'];


      // frequent cold part

      String? symptomsfcold = _responses['symptomsfcold'];
      String? colds = _responses['colds'];
      String? triggers = _responses['triggers'];
      selectedOptions = selectedOptions;

      String? nasal = _responses['nasal'];
      String? cough = _responses['cough'];
      String? severe = _responses['severe'];
      String? significantly = _responses['significantly'];
      String? medical = _responses['medical'];
      String? chronic = _responses['chronic'];
      String? immune = _responses['immune'];
      String? flu = _responses['flu'];



      // fatigue part
      String? fatigue = _responses['fatigue'];
      String? fatigued = _responses['fatigued'];
      String? sleep = _responses['sleep'];
      String? lifestyle = _responses['lifestyle'];

      // shortness oof breath

      String? deterioration = _responses['deterioration'];
      String? chest = _responses['chest'];
      String? oxygen = _responses['oxygen'];




      // coughing of blood

      String? coughingOfBlood = _responses['Coughing of Blood'];
      String? pain = _responses['pain'];
      String? happening = _responses['happening'];
      String? onset = _responses['onset'];
      String? bright = _responses['bright'];
      String? clots = _responses['clots'];
      String? medications = _responses['medications'];


      String? swallowing = _responses['swallowing'];
      String? throat = _responses['throat'];
      String? eating = _responses['eating'];
      String? snore = _responses['snore'];
      String? quality = _responses['quality'];
      String? allergy = _responses['allergy'];
      String? caner = _responses['caner'];


      String? diet = _responses['diet'];
      String? shortness = _responses['shortness'];



      String? ability = _responses['ability'];
      String? energy = _responses['energy'];
      String? tasks = _responses['tasks'];
      String? mood = _responses['mood'];
      String? relationships = _responses['relationships'];

      //
      // List<String> smoking = []; // Array for smoking data
      // List<String> passiveSmoking = []; // Array for passive smoking data
      // List<String> alcohols = []; // Array for alcohol data
      // List<String> frequentCold = []; // Array for frequent cold data
      // List<String> fatigues = []; // Array for fatigue data
      // List<String> shortnessOfBreath = []; // Array for shortness of breath data
      // List<String> coughingOfBlood = []; // Array for coughing of blood data
      // List<String> Quality = []; // Array for sleep quality data (combined throat, eating, snore, quality)
      // List<String> general = []; // Array for remaining variables (diet, shortness)
      //
      //
      //
      //
      // smoking.add(smoke!);
      // smoking.add(attempts!);
      // smoking.add(cravings!);
      // smoking.add(staining!);
      //
      // passiveSmoking.add(spend!);
      // passiveSmoking.add(exposed!);
      // passiveSmoking.add(live!);
      // passiveSmoking.add(symptoms!);
      //
      //
      // alcohols.add(_responses['alcohol']!);
      // alcohols.add(_responses['typical']!);
      // alcohols.add(_responses['occasion']!);
      // alcohols.add(_responses['stop']!);
      // alcohols.add (_responses['failed']!);
      // alcohols.add (_responses['needed']!);
      // alcohols.add (_responses['feeling']!);
      // alcohols.add (_responses['remember']!);
      // alcohols.add (_responses['injured']!);
      // alcohols.add (_responses['relative']!);
      //
      //
      //
      //
      //
      // frequentCold.add(symptomsfcold!);
      // frequentCold.add(colds!);
      // frequentCold.add(triggers!);
      // frequentCold.add(nasal!);
      // frequentCold.add(cough!);
      // frequentCold.add(severe!);
      // frequentCold.add(significantly!);
      // frequentCold.add(medical!);
      // frequentCold.add(chronic!);
      // frequentCold.add(immune!);
      // frequentCold.add(flu!);
      //
      //
      //
      //
      // fatigues.add(fatigue!);
      // fatigues.add(fatigued!);
      // fatigues.add(sleep!);
      // fatigues.add(lifestyle!);
      //
      //
      //
      //
      //
      // shortnessOfBreath.add(deterioration!);
      // shortnessOfBreath.add(chest!);
      // shortnessOfBreath.add(oxygen!);
      //
      //
      //
      // coughingOfBlood.add(Coughing_of_Blood!);
      // coughingOfBlood.add(pain!);
      // coughingOfBlood.add(happening!);
      // coughingOfBlood.add(onset!);
      // coughingOfBlood.add(bright!);
      // coughingOfBlood.add(clots!);
      // coughingOfBlood.add(medications!);
      //
      //
      //
      // Quality.add(swallowing!);
      // Quality.add(throat!);
      // Quality.add(eating!);
      // Quality.add(snore!);
      // Quality.add(quality!);
      // Quality.add(allergy!);
      // Quality.add(caner!);
      //
      //
      //
      // general.add(diet!);
      // general.add(shortness!);


//
//       // frequentCold.add();
//
//
//       List<String> allValues = [];
//
// // Add values from each section:
//       allValues.addAll(smoking);
//       allValues.addAll(passiveSmoking);
//       allValues.addAll(alcohols);
//       allValues.addAll(frequentCold);
//       allValues.addAll(fatigues);
//       allValues.addAll(shortnessOfBreath);
//       allValues.addAll(coughingOfBlood);
//       allValues.addAll(Quality);
//       allValues.addAll(general);
//       allValues.addAll(selectedOptions);

      // startUpload();

      int smokeResult = 0;
      int passiveSmokeResult = 0;
      int alchoholResult = 0;
      int frequentResult=0;
      int fatigueResult=0;
      int shortnessResult=0;
      int coughingResult=0;
      int swallowingResult=0;
      int snoreResult=0;
      int airResult=0;
      int allergyResult=0;
      int geneticResult=0;
      int dietResult=0;
      int dryResult=0;

      if(smoke == 'smoke1'){
        smokeResult+=0;
      }
      else if(smoke == 'smoke2'){
        smokeResult+=1;
      }
      else if(smoke == 'smoke3'){
        smokeResult+=2;
      }
      else if(smoke == 'smoke4'){
        smokeResult+=3;
      }
      else if(smoke == 'smoke5'){
        smokeResult+=4;
      }
      else if(smoke == 'smoke6'){
        smokeResult+=5;
      }
      else if(smoke == 'smoke7'){
        smokeResult+=6;
      }




      if(attempts == 'Yes1'){
       smokeResult +=1;
      }
      else if(attempts == 'No1'){
        smokeResult+=0;
      }


      if (cravings == 'yes2'){
        smokeResult += 1 ;
      }
      else if(cravings == 'no2'){
        smokeResult+=0;
      }


      if (staining == 'yes3'){
        smokeResult += 1 ;
      }
      else if(staining == 'no3'){
        smokeResult+=0;
      }


      if(spend == 'yes4'){
        passiveSmokeResult+=1;
      }
      else if(spend == 'no4'){
        passiveSmokeResult+=0;
      }

      if(exposed == 'yes5'){
        passiveSmokeResult+=1;
      }
      else if(exposed == 'no5'){
        passiveSmokeResult+=0;
      }

      if(symptoms == 'yes6'){
        passiveSmokeResult+=1;
      }
      else if(symptoms == 'no6'){
        passiveSmokeResult+=0;
      }

      if(live == 'yes7'){
        passiveSmokeResult+=1;
      }
      else if(live == 'no7'){
        passiveSmokeResult+=0;
      }


      if(alcohol == 'ans1'){
        alchoholResult+=0;
      }
      else if(alcohol == 'ans2'){
        alchoholResult+=1;
      }
      else if(alcohol == 'ans3'){
        alchoholResult+=2;
      }
      else if(alcohol == 'ans4'){
        alchoholResult+=3;
      }
      else if(alcohol == 'ans5'){
        alchoholResult+=4;
      }

      if(typical == 'ans6'){
        alchoholResult+=0;
      }
      else if(typical == 'ans7'){
        alchoholResult+=1;
      }
      else if(typical == 'ans8'){
        alchoholResult+=2;
      }
      else if(typical == 'ans9'){
        alchoholResult+=3;
      }
      else if(typical == 'ans10'){
        alchoholResult+=4;
      }


      if(occasion == 'ans11'){
        alchoholResult+=0;
      }
      else if(occasion == 'ans12'){
        alchoholResult+=1;
      }
      else if(occasion == 'ans13'){
        alchoholResult+=2;
      }
      else if(occasion == 'ans14'){
        alchoholResult+=3;
      }
      else if(occasion == 'ans15'){
        alchoholResult+=4;
      }


      if(stop == 'ans16'){
        alchoholResult+=0;
      }
      else if(stop == 'ans17'){
        alchoholResult+=1;
      }
      else if(stop == 'ans18'){
        alchoholResult+=2;
      }
      else if(stop == 'ans19'){
        alchoholResult+=3;
      }
      else if(stop == 'ans20'){
        alchoholResult+=4;
      }


      if(failed == 'ans21'){
        alchoholResult+=0;
      }
      else if(failed == 'ans22'){
        alchoholResult+=1;
      }
      else if(failed == 'ans23'){
        alchoholResult+=2;
      }
      else if(failed == 'ans24'){
        alchoholResult+=3;
      }
      else if(failed == 'ans25'){
        alchoholResult+=4;
      }

      if(needed == 'ans26'){
        alchoholResult+=0;
      }
      else if(needed == 'ans27'){
        alchoholResult+=1;
      }
      else if(needed == 'ans28'){
        alchoholResult+=2;
      }
      else if(needed == 'ans29'){
        alchoholResult+=3;
      }
      else if(needed == 'ans30'){
        alchoholResult+=4;
      }


      if(feeling == 'ans31'){
        alchoholResult+=0;
      }
      else if(feeling == 'ans32'){
        alchoholResult+=1;
      }
      else if(feeling == 'ans33'){
        alchoholResult+=2;
      }
      else if(feeling == 'ans34'){
        alchoholResult+=3;
      }
      else if(feeling == 'ans35'){
        alchoholResult+=4;
      }

      if(remember == 'ans36'){
        alchoholResult+=0;
      }
      else if(remember == 'ans37'){
        alchoholResult+=1;
      }
      else if(remember == 'ans38'){
        alchoholResult+=2;
      }
      else if(remember == 'ans39'){
        alchoholResult+=3;
      }
      else if(remember == 'ans40'){
        alchoholResult+=4;
      }

      if(injured == 'ans41'){
        alchoholResult+=0;
      }
      else if(injured == 'ans42'){
        alchoholResult+=2;
      }
      else if(injured == 'ans43'){
        alchoholResult+=4;
      }



      if(relative == 'ans44'){
        alchoholResult+=0;
      }
      else if(relative == 'ans45'){
        alchoholResult+=2;
      }
      else if(relative == 'ans46'){
        alchoholResult+=4;
      }


      if(symptomsfcold == 'ans47'){
        frequentResult+=0;
      }
      else if(symptomsfcold == 'ans48'){
        frequentResult+=3;
      }
      else if(symptomsfcold == 'ans49'){
        frequentResult+=2;
      }
      else if(symptomsfcold == 'ans50'){
        frequentResult+=1;
      }


      if(colds == 'ans51'){
        frequentResult+=1;
      }
      else if(colds == 'ans52'){
        frequentResult+=2;
      }
      else if(colds == 'ans53'){
        frequentResult+=3;
      }


      if(triggers == 'yes8'){
        frequentResult+=1;
      }
      else if(triggers == 'no8'){
        frequentResult+=0;
      }


      for(int i = 0 ; i < selectedOptions.length ; i++){
        if(selectedOptions[i] == 'ans54'){
          frequentResult+=1;
        }
        else if(selectedOptions[i] == 'ans55'){
          frequentResult+=2;
        }
        else if(selectedOptions[i] == 'ans56'){
          frequentResult+=3;
        }
        // print(selectedOptions[i]);
      }

      if(nasal == 'yes9'){
        frequentResult+=1;
      }
      else if(nasal == 'no9'){
        frequentResult+=0;
      }

      if(cough == 'yes10'){
        frequentResult+=1;
      }
      else if(cough == 'no10'){
        frequentResult+=0;
      }

      if(severe == 'ans57'){
        frequentResult+=0;
      }
      else if(severe == 'ans58'){
        frequentResult+=1;
      }
      else if(severe == 'ans59'){
        frequentResult+=2;
      }

      if(significantly == 'yes11'){
        frequentResult+=1;
      }
      else if(significantly == 'no11'){
        frequentResult+=0;
      }



      if(medical == 'yes12'){
        frequentResult+=1;
      }
      else if(medical == 'no12'){
        frequentResult+=0;
      }


      if(chronic == 'yes13'){
        frequentResult+=1;
      }
      else if(chronic == 'no13'){
        frequentResult+=0;
      }


      if(immune == 'yes14'){
        frequentResult+=1;
      }
      else if(immune == 'no14'){
        frequentResult+=0;
      }


      if(flu == 'yes15'){
        frequentResult+=1;
      }
      else if(flu == 'no15'){
        frequentResult+=0;
      }



      if(fatigue == 'ans60'){
        fatigueResult+=1;
      }
      else if(fatigue == 'ans61'){
        fatigueResult+=2;
      }
      else if(fatigue == 'ans62'){
        fatigueResult+=3;
      }
      else if(fatigue == 'ans63'){
        fatigueResult+=4;
      }


      if(fatigued == 'yes16'){
        fatigueResult+=1;
      }
      else if(fatigued == 'no16'){
        fatigueResult+=2;
      }
      else if(fatigued == 'answer1'){
        fatigueResult+=3;
      }
      else if(fatigued == 'answer2'){
        fatigueResult+=4;
      }



      if(sleep == 'ans64'){
        fatigueResult+=1;
      }
      else if(sleep == 'ans65'){
        fatigueResult+=2;
      }
      else if(sleep == 'ans66'){
        fatigueResult+=3;
      }
      else if(sleep == 'answer3'){
        fatigueResult+=4;
      }


      if(lifestyle == 'ans67'){
        fatigueResult+=1;
      }
      else if(lifestyle == 'ans68'){
        fatigueResult+=2;
      }
      else if(lifestyle == 'ans69'){
        fatigueResult+=3;
      }

      else if(lifestyle == 'answer4'){
        fatigueResult+=4;
      }

      if(ability == 'answer5'){
        fatigueResult+=1;
      }
      else if(ability == 'answer6'){
        fatigueResult+=2;
      }
      else if(ability == 'answer7'){
        fatigueResult+=3;
      }
      else if(ability == 'answer8'){
        fatigueResult+=4;
      }



      if(energy == 'answer9'){
        fatigueResult+=1;
      }
      else if(energy == 'answer10'){
        fatigueResult+=2;
      }
      else if(energy == 'answer11'){
        fatigueResult+=3;
      }
      else if(energy == 'answer12'){
        fatigueResult+=4;
      }



      if(mood == 'answer13'){
        fatigueResult+=1;
      }
      else if(mood == 'answer14'){
        fatigueResult+=2;
      }
      else if(mood == 'answer15'){
        fatigueResult+=3;
      }
      else if(mood == 'answer16'){
        fatigueResult+=4;
      }


      if(tasks == 'answer17'){
        fatigueResult+=1;
      }
      else if(tasks == 'answer18'){
        fatigueResult+=2;
      }
      else if(tasks == 'answer19'){
        fatigueResult+=3;
      }
      else if(tasks == 'answer20'){
        fatigueResult+=4;
      }



      if(relationships == 'answer21'){
        fatigueResult+=1;
      }
      else if(relationships == 'answer22'){
        fatigueResult+=2;
      }
      else if(relationships == 'answer23'){
        fatigueResult+=3;
      }
      else if(relationships == 'answer24'){
        fatigueResult+=4;
      }



      if(deterioration == 'ans70'){
        shortnessResult+=1;
      }
      else if(deterioration == 'ans71'){
        shortnessResult+=2;
      }


      if(chest == 'yes17'){
        shortnessResult+=1;
      }
      else if(chest == 'no17'){
        shortnessResult+=0;
      }

      if(oxygen == 'ans72'){
        shortnessResult+=1;
      }
      else if(oxygen == 'ans73'){
        shortnessResult+=2;
      }
      else if(oxygen == 'ans74'){
        shortnessResult+=3;
      }


      if(coughingOfBlood == 'yes18'){
        coughingResult+=1;
      }
      else if(coughingOfBlood == 'no18'){
        coughingResult+=0;
      }

      if(pain == 'yes19'){
        coughingResult+=1;
      }
      else if(pain == 'no19'){
        coughingResult+=0;
      }


      if(happening == 'ans75'){
        coughingResult+=1;
      }
      else if(happening == 'ans76'){
        coughingResult+=2;
      }
      else if(happening == 'ans77'){
        coughingResult+=3;
      }
      else if(happening == 'ans78'){
        coughingResult+=4;
      }



      if(onset == 'ans79'){
        coughingResult+=1;
      }
      else if(onset == 'ans80'){
        coughingResult+=2;
      }


      if(bright == 'ans81'){
        coughingResult+=1;
      }
      else if(bright == 'ans82'){
        coughingResult+=2;
      }


      if(clots == 'ans83'){
        coughingResult+=1;
      }
      else if(clots == 'ans84'){
        coughingResult+=0;
      }


      if(medications == 'ans85'){
        coughingResult+=1;
      }
      else if(medications == 'ans86'){
        coughingResult+=0;
      }




      if(swallowing == 'ans87'){
        swallowingResult+=1;
      }
      else if(swallowing == 'ans88'){
        swallowingResult+=2;
      }
      else if(swallowing == 'ans89'){
        swallowingResult+=3;
      }
      else if(swallowing == 'ans90'){
        swallowingResult+=4;
      }
      else if(swallowing == 'ans91'){
        swallowingResult+=5;
      }



      if(throat == 'yes20'){
        swallowingResult +=1;
      }
      else if(throat == 'no20'){
        swallowingResult+=0;
      }


      if(eating  == 'yes21'){
        swallowingResult+=1;
      }
      else if(eating == 'no21'){
        swallowingResult+=0;
      }


      if(snore == 'yes22'){
        snoreResult+=1;
      }
      else if(snore == 'no22'){
        snoreResult+=0;
      }

      if(quality == 'no23'){
        airResult+=0;
      }
      else if(quality == 'ans92'){
        airResult +=1;
      }
      else if(quality == 'yes23'){
        airResult+=2;
      }


      if(allergy == 'no24'){
        allergyResult+=0;
      }
      else if(allergy == 'ans93'){
        allergyResult+=1;
      }
      else if(allergy == 'yes24'){
        allergyResult+=2;
      }



      if(caner == 'no25'){
        geneticResult+=0;
      }
      else if(caner == 'ans94'){
        geneticResult+=1;
      }
      else if(caner == 'yes25'){
        geneticResult+=2;
      }


      if(diet == 'no26'){
        dietResult+=0;
      }
      else if(diet == 'ans95'){
        dietResult+=1;
      }
      else if(diet == 'yes26'){
        dietResult+=2;
      }

      if(shortness == 'no27'){
        dryResult+=0;
      }
      else if(shortness == 'ans96'){
        dryResult+=1;
      }
      else if(shortness == 'yes27'){
        dryResult+=2;
      }


      double smokeHost = ((smokeResult/8).roundToDouble()) ;
      double passivesmokerHost = ((passiveSmokeResult/8).roundToDouble()) ;
      double alcoholHost = ((alchoholResult/8).roundToDouble()) ;
      double frequentcoldHost = ((frequentResult/7).roundToDouble());
      double fatigueHost = ((fatigueResult/9).roundToDouble());
      double shortnessHost = ((shortnessResult/9).roundToDouble()) ;
      double coughingbloodHost = ((coughingResult/9).roundToDouble()) ;
      double swallowingHost = ((swallowingResult/8).roundToDouble()) ;
      double snoringHost = ((snoreResult/7).roundToDouble()) ;
      double airHost = ((airResult/8).roundToDouble()) ;
      double allergyHost = ((allergyResult/8).roundToDouble()) ;
      double geneticHost = ((geneticResult/7).roundToDouble()) ;
      double dietHost = ((dietResult/7).roundToDouble()) ;
      double dryHost = ((dryResult/7).roundToDouble());

      if(alcoholHost >=0 && allergyHost < 8 ){
        allergyHost = 0;
      }
      else if(alcoholHost >=8 || allergyHost < 16){
        allergyHost = 1;
      }

      else if(alcoholHost >=16 || allergyHost < 20){
        allergyHost = 2;
      }
      else if(alcoholHost >=20 || allergyHost < 41){
        allergyHost = 3;
      }











      int smokeHost2 = smokeHost.toInt() ;
      int passivesmokerHost2 = passivesmokerHost.toInt();
      int alcoholHost2 = alcoholHost.toInt();
      int frequentcoldHost2 = frequentcoldHost.toInt();
      int fatigueHost2 = fatigueHost.toInt();
      int shortnessHost2 = shortnessHost.toInt();
      int coughingbloodHost2 = coughingbloodHost.toInt();
      int swallowingHost2 = swallowingHost.toInt();
      int snoringHost2 = snoringHost.toInt();
      int airHost2 = airHost.toInt();
      int allergyHost2 = allergyHost.toInt();
      int geneticHost2 = geneticHost.toInt();
      int dietHost2 = dietHost.toInt();
      int dryHost2 = dryHost.toInt();



      // print('------------------------');
      // print(smokeHost2);
      // print(passivesmokerHost2);





      hostedAttributes.add(int.parse(_textFieldControllerAge.text));
      hostedAttributes.add(airHost2);
      hostedAttributes.add(alcoholHost2);
      hostedAttributes.add(allergyHost2);
      hostedAttributes.add(geneticHost2);
      hostedAttributes.add(dietHost2);
      hostedAttributes.add(smokeHost2);
      hostedAttributes.add(passivesmokerHost2);
      hostedAttributes.add(coughingbloodHost2);
      hostedAttributes.add(fatigueHost2);
      hostedAttributes.add(shortnessHost2);
      hostedAttributes.add(swallowingHost2);
      hostedAttributes.add(0);
      hostedAttributes.add(frequentcoldHost2);
      hostedAttributes.add(dryHost2);
      hostedAttributes.add(snoringHost2);
startUpload();
      void showCustomDialog(BuildContext context, String title, String content) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
