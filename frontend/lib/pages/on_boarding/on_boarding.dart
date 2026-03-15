import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:supabase/src/supabase_client.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage(SupabaseClient supabaseClient, {super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(backgroundColor: Colors.deepPurple,

     body: Center(child: ElevatedButton(onPressed:() async {
       await ClerkAuth.of(context).signOut();
     }, child: Text('Log-out')),),
       );
  }

}