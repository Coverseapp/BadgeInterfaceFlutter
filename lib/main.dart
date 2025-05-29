import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';




void main() {
  	runApp(MyApp());
}

class MyApp extends StatelessWidget{
  	@override
	Widget build(BuildContext context){
		return MaterialApp(
			title: "Admin Panel",
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: BadgeFormPage(),
		);
	} 
}

//The Left Form Input Widgets
class BadgeFormPage extends StatefulWidget
{
	@override
	_BadgeFormPageState createState() => _BadgeFormPageState();
}

class _BadgeFormPageState extends State<BadgeFormPage> {

	List<BadgeFormNewInput> inputFields = [];
	List<BadgeFormNewInput> conditionFields = [];

	List<TextEditingController> controllers = [];
	List<TextEditingController> conditionControllers = [];

	List<String> labels = [];
	List<String> conditionLabels = [];

	String? jsonPreview;

	int selectedValue = 0;

	@override
	void initState() 
	{
    	super.initState();
		controllers.add(TextEditingController()); // main controller to add new inputs
		controllers.add(TextEditingController());
		controllers.add(TextEditingController());
		controllers.add(TextEditingController());
		controllers.add(TextEditingController());

		conditionControllers.add(TextEditingController());

		labels.add("Add a New Key");
		labels.add("name");
		labels.add("display_name");
		labels.add("refresh_rate");
		labels.add("is_permanent_true");

		conditionLabels.add("Add Condition");
  	}

	void _addInputField(label)
	{
		setState(() {
			if(label == "") return;

			if(!labels.contains(label))
			{	
				switch (selectedValue) {
				  case 0:
				    	controllers.add(TextEditingController());
						inputFields.add(BadgeFormNewInput(
						label: label,
						controller: controllers.last,
						inputFormatters: FilteringTextInputFormatter.digitsOnly,
						onRemove: () => _deleteInputField() ,
						));
						labels.add(label);
				    break;
				  case 1:
						controllers.add(TextEditingController());
						inputFields.add(BadgeFormNewInput(
						label: label,
						controller: controllers.last,
						inputFormatters:  FilteringTextInputFormatter.allow(RegExp(r'.*')),
						onRemove: () => _deleteInputField() ,
						));
						labels.add(label);
				}
				
			}
		});
	}

	void _deleteInputField()
	{
		setState(() {
			for(int i = 0; i < inputFields.length ; i++){
				if(inputFields[i].getIsToBeDeleted == true)
				{
					controllers.removeAt(i);
					String labetToBeDeleted = inputFields[i].getLabel;
					labels.remove(labetToBeDeleted);
					inputFields.removeAt(i);
				}
			}
		});
	}

	void _addConditionField(label)
	{
		setState(() {
			if(label == "") return;

			if(!conditionLabels.contains(label))
			{
				switch (selectedValue) {
				  case 0:
				    conditionControllers.add(TextEditingController());
					conditionFields.add(BadgeFormNewInput(
						label: label,
						controller: conditionControllers.last,
						inputFormatters: FilteringTextInputFormatter.digitsOnly,
						onRemove: () => _deleteConditionField() ,
					));
					conditionLabels.add(label);
				    break;
				case 1: 
					conditionControllers.add(TextEditingController());
					conditionFields.add(BadgeFormNewInput(
						label: label,
						controller: conditionControllers.last,
						inputFormatters: FilteringTextInputFormatter.allow(RegExp(r'.*')),
						onRemove: () => _deleteConditionField() ,
					));
					break;
				}
				
			}
		});
	}

	void _deleteConditionField()
	{
		setState(() {
			for(int i = 0; i < conditionFields.length ; i++){
				if(conditionFields[i].getIsToBeDeleted == true)
				{
					conditionControllers.removeAt(i);
					String labetToBeDeleted = conditionFields[i].getLabel;
					conditionLabels.remove(labetToBeDeleted);
					conditionFields.removeAt(i);
				}
			}
		});
	}

	Future<void>  _preview() async {
		Map map = {};
		Map conditions = {};
		for(int i = 1; i < labels.length; i++)
		{
			print("$i ${labels[i]} ${controllers[i].text.trim()} ");
			map[labels[i]] = controllers[i].text.trim();
		}
		for(int i = 1 ; i < conditionLabels.length; i++)
		{
			conditions[conditionLabels[i]] = conditionControllers[i].text.trim();
		}
		map["conditions"] = conditions;

		setState(() {
    		jsonPreview = const JsonEncoder.withIndent('  ').convert(map); // nicely formatted JSON
  		});
	}

  	@override
 	Widget build(BuildContext context) {
    	return Scaffold(
      	appBar: AppBar(title: Text("data")),
      	body: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				SingleChildScrollView(
        			padding: const EdgeInsets.all(20),
        			child: SizedBox(
						width: 400,
						child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Expanded(
											flex: 1,
											child: BadgeFormInput(label: "Add a New Key", controller: controllers[0]),
											),
											SizedBox(height: 20, width: 20),
											DropdownButton<int>(
											value: selectedValue, // You'll need to define this variable in your state
											items: [0, 1].map((int value) {
												return DropdownMenuItem<int>(
												value: value,
												child: Text('$value'),
												);
											}).toList(),
											onChanged: (int? newValue) {
												setState(() {
												selectedValue = newValue!;
												});
											},
											),
											ElevatedButton(
											onPressed: (){
												_addInputField(controllers.first.text.trim());
												controllers.first.text = "";
											},
											child: Text("+")
											)
									],
								),
									BadgeFormInput(label: "name", controller: controllers[1]),
									BadgeFormInput(label: "display_name", controller: controllers[2]),
									BadgeFormInput(label: "refresh_rate", controller: controllers[3]),
									BadgeFormInput(label: "is_permanent_true", controller: controllers[4]),
									...inputFields,
									Row(
										children: [
											Expanded(
												flex: 1,
												child: BadgeFormInput(label: "Add Condition", controller: conditionControllers[0]),
												),
											SizedBox(height: 20, width: 20),
											ElevatedButton(
												onPressed: (){
												_addConditionField(conditionControllers.first.text.trim());
												controllers.first.text = "";
												},
												child: Text("+")
											)
										],
									),
									...conditionFields
								],
							),
						), 
					),
				Column(
					children: [
						FilePickerExample(),
						if (jsonPreview != null)
							Padding(
								padding: const EdgeInsets.only(top: 16),
								child: SingleChildScrollView(
									scrollDirection: Axis.horizontal,
									child: SizedBox(
										child: Text(
											jsonPreview!,
											style: TextStyle(fontFamily: 'monospace'), // makes it look like JSON
										)
									),
								),
							),
					],
				),
				Column(
					crossAxisAlignment: CrossAxisAlignment.end,
					children: [
						Expanded(child: Container()),
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // Makes buttons side by side
							children: [
							Padding(
								padding: EdgeInsets.all(4),
								child: ElevatedButton(
									onPressed: _preview,
									child: Text("Preview As JSON"),
								),
							),
							Padding(
								padding: EdgeInsets.all(4),
								child: ElevatedButton(
									onPressed: _preview,
									child: Text("Send to DB"),
									),
									),
								],
							)
						],
					)
				]
			)
		); 
	}
}
				
class BadgeFormInput extends StatelessWidget
{
	final String label;
	final TextEditingController controller;
	final bool isToBeDeleted = false;
	
	const BadgeFormInput({
		super.key,
		required this.label,
		required this.controller
	});

	bool get getIsToBeDeleted {
		return isToBeDeleted;
	}

	@override 
	Widget build(BuildContext context)
	{
		return Padding(
			padding: EdgeInsets.all(4),
			child: TextField(
				controller: controller,
				decoration: InputDecoration(
					labelText: label,
					border: OutlineInputBorder(),
				),
			),
		);
	}
}

class BadgeFormNewInput extends StatelessWidget
{
	final TextEditingController controller;
	final String label;
	bool isToBeDeleted = false;
	final VoidCallback onRemove;
	final TextInputFormatter inputFormatters;


	BadgeFormNewInput({
		super.key,
		required this.controller,
		required this.label,
		required this.onRemove,
		required this.inputFormatters
	});

	String get getLabel{
		return label;
	}

	set setIsToBeDeleted(bool b){
		isToBeDeleted = b;
	}

	bool get getIsToBeDeleted {
		return isToBeDeleted;
	}

	@override
	Widget build(BuildContext context)
	{
		return Padding(
			padding: EdgeInsets.all(4),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Expanded(
						flex: 1,
						child: BadgeFormInput(label: label, controller: controller),
					),
					SizedBox(height: 20, width: 20,),

					ElevatedButton(
						onPressed: ()  {
							setIsToBeDeleted = true;
							onRemove.call();
						},
						child: Text("-"))
				],
			),
		);
	}
}

//End Of Left Widget Elements

class FilePickerExample extends StatefulWidget {
  @override
  _FilePickerExampleState createState() => _FilePickerExampleState();
}

class _FilePickerExampleState extends State<FilePickerExample> {
  Uint8List? _imageBytes;
  String _fileName = "No file selected";

  void _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true, // Needed to get `bytes`
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes!;
        _fileName = result.files.single.name;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
    	children:[
			Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
				children: [
					ElevatedButton(
					onPressed: _pickImage,
					child: Text("Select Image"),
					),
					SizedBox(height: 20),
					Text("Selected: $_fileName"),
					SizedBox(height: 20),
					if (_imageBytes != null)
					Image.memory(_imageBytes!, width: 200),
				],
				),
			),
		] 
    );
  }
}

