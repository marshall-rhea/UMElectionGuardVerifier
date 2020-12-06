import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/data/user.dart';
import 'package:errand_share/data/database.dart';
import 'package:errand_share/services/square.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:errand_share/component/roundButton.dart';
import 'package:errand_share/services/geoService.dart';

class RequestCreateScreen extends StatefulWidget {
  final User user;
  RequestCreateScreen(this.user);
  @override
  State createState() => _RequestCreateState(user);
}

class _RequestCreateState extends State<RequestCreateScreen> {
  User user;
  _RequestCreateState(this.user);
  final formKey = GlobalKey<FormState>();
  DateTime _start_time;
  DateTime _finish_time;
  TextEditingController _start_time_controller;
  TextEditingController _finish_time_controller;
  TextEditingController _start_address_controller;
  TextEditingController _drop_off_address_controller;

  final _controller = TextEditingController();

  String _start_address;
  String _drop_off_address;
  String _description;

  String _task_cost;
  String _bounty;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _start_time_controller.dispose();
    _finish_time_controller.dispose();
    _start_address_controller.dispose();
    _drop_off_address_controller.dispose();
    super.dispose();
  }

  Future<TimeOfDay> _selectTime(BuildContext context) {
    final now = DateTime.now();

    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
  }

  Future<DateTime> _selectDateTime(BuildContext context) => showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(seconds: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  // Validate the format of the form and login
  void validateAndSubmit() {
    if (validateAndSave()) {
      //check that the end time is after the start time
      if (_finish_time.isBefore(_start_time)) {
        print('End Time cannot be before Start Time');
        resetForm();
        Navigator.pop(context);
      }
      var newBounty = Bounty(
          user.uid,
          _bounty,
          _task_cost,
          _description,
          _drop_off_address,
          _start_address,
          _start_time.toString(),
          _finish_time.toString(),
          DateTime.now().toString(),
          '0');
      Square().createPayment(int.parse(_task_cost));
      //progress defaulted to 0 when created. Upon acceptance, =1, upon completion = 2
      Database().createBounty(newBounty).then((_) => Navigator.pop(context));
    } else {
      return;
    }
  }

  void cancle() {
    resetForm();
    Navigator.pop(context);
  }

  void resetForm() {
    _start_time = null;
    _finish_time = null;
    _start_time_controller.clear();
    _finish_time_controller.clear();
    formKey.currentState.reset();
  }

  @override
  void initState() {
    _start_time_controller = TextEditingController(text: '');
    _finish_time_controller = TextEditingController(text: '');
    _start_address_controller = TextEditingController(text: '');
    _drop_off_address_controller = TextEditingController(text: '');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(fit: StackFit.expand, children: <Widget>[
        ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, bottom: 10),
                  child: Text('Post New Job',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                      textAlign: TextAlign.left),
                )
              ],
            ),
            Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                            controller: _start_address_controller,
                            readOnly: true,
                            decoration: InputDecoration(
                                labelText: 'Start Address',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value.isEmpty
                                ? 'Start address can\'t be empty'
                                : null,
                            onTap: () => {
                              GeoService()
                                  .addressAutoFill(context)
                                  .then((prediction) => {
                                        if (prediction != null)
                                          {
                                            setState(() {
                                              _start_address_controller.text =
                                                  prediction.item1;
                                              _start_address = prediction.item2;
                                            }),
                                          }
                                        else
                                          {
                                            setState(() {
                                              _start_address_controller.clear();
                                              _start_address = null;
                                            }),
                                          }
                                      })
                            },
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10.0)),
                        Flexible(
                          child: TextFormField(
                            controller: _drop_off_address_controller,
                            readOnly: true,
                            decoration: InputDecoration(
                                labelText: 'Dropoff Address',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value.isEmpty
                                ? 'Dropoff address can\'t be empty'
                                : null,
                            onTap: () => {
                              GeoService()
                                  .addressAutoFill(context)
                                  .then((prediction) => {
                                        if (prediction != null)
                                          {
                                            setState(() {
                                              _drop_off_address_controller
                                                  .text = prediction.item1;
                                              _drop_off_address =
                                                  prediction.item2;
                                            }),
                                          }
                                        else
                                          {
                                            setState(() {
                                              _drop_off_address_controller
                                                  .clear();
                                              _drop_off_address = null;
                                            }),
                                          }
                                      })
                            },
                          ),
                        )
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                            onTap: () async {
                              final selectedDate =
                                  await _selectDateTime(context);
                              if (selectedDate == null) return;
                              final selectedTime = await _selectTime(context);
                              if (selectedTime == null) return;
                              setState(() {
                                _start_time = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute);
                                _start_time_controller.text =
                                    _start_time.toString();
                              });
                            },
                            decoration: InputDecoration(
                                labelText: 'Start Time',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            controller: _start_time_controller,
                            readOnly: true,
                            validator: (value) => value.isEmpty
                                ? 'Start Time can\'t be empty'
                                : null,
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10.0)),
                        Flexible(
                          child: TextFormField(
                            onTap: () async {
                              print('GestureDetector triggered');
                              final selectedDate =
                                  await _selectDateTime(context);
                              if (selectedDate == null) return;
                              final selectedTime = await _selectTime(context);
                              if (selectedTime == null) return;
                              setState(() {
                                _finish_time = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute);
                                _finish_time_controller.text =
                                    _finish_time.toString();
                              });
                            },
                            decoration: InputDecoration(
                                labelText: 'Finish Time',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            controller: _finish_time_controller,
                            readOnly: true,
                            validator: (value) => value.isEmpty
                                ? 'Finish Time can\'t be empty'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          alignLabelWithHint: true),
                      keyboardType: TextInputType.text,
                      maxLines: 10,
                      validator: (value) =>
                          value.isEmpty ? 'Description can\'t be empty' : null,
                      onSaved: (value) => _description = value,
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Task Cost',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            keyboardType: TextInputType.number,
                            onSaved: (value) => _task_cost = value,
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10.0)),
                        Flexible(
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Bounty',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            validator: (value) => (user.isPrivileged == false &&
                                    (int.parse(value) > user.tokens ||
                                        int.parse(value) <= 0))
                                ? 'You don\'t have enough tokens, tokens for request must be greater than 0'
                                : null,
                            onSaved: (value) => _bounty = value,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(10.0)),
                Expanded(
                  child: RoundedButton(
                    text: 'Post',
                    buttonColor: Colors.blue,
                    textColor: Colors.white,
                    press: validateAndSubmit,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Expanded(
                  child: RoundedButton(
                    text: 'Cancel',
                    buttonColor: Colors.grey,
                    textColor: Colors.black,
                    press: cancle,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
              ],
            )
          ],
        )
      ]),
    );
  }
}
