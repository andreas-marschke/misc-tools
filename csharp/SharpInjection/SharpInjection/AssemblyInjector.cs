//
//  AssemblyInjector.cs
//
//  Author:
//       Andreas Marschke <xxtjaxx@gmail.com>
// 
//  Copyright (c) 2010 Andreas Marschke
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

using System;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace SharpInjection
{
	/// <summary>
	/// AssemblyInjector is the heart of this demonstration it will inject arbitrary,bytecompiled code 
	/// into assemblies given by the user. 
	/// </summary>
	public class AssemblyInjector
	{
		private string HostFile_;
		private string NewHostName_;
		private System.Type ReturnType_;
		
		/// <summary>
		/// Host executable/assembly which will be modified.
		/// </summary>
		public string HostFile 
		{
			get{return HostFile;}
			set{HostFile = value;}
			
		}
		/// <summary>
		/// Name of the new executable/assembly.
		/// Unless explicitely specified it's set to <see cref="HostFile"/>
		/// </summary>
		public string NewHostName
		{
			get{return NewHostName_;}
			set{
				if(value == "")
				{
					NewHostName_ = HostFile;					
				} else {
					NewHostName_ = value;
				}
			}
		}
		/// <summary>
		/// Returned System.Type of the injected function.
		/// </summary>
		public System.Type ReturnType
		{
			get{return ReturnType_;}
			set{ReturnType_=value;}
		}
		
		/// <summary>
		/// Constructor of AssemblyInjector
		/// </summary>
		/// <param name="HostFile">
		/// A <see cref="System.String"/>
		/// The Host we will act upon and in which the code will be injected.
		/// </param>
		/// <param name="NewHostName">
		/// A <see cref="System.String"/>
		/// You can specify a new filename for the new "patched" executable.
		/// </param>
		/// <param name="ReturnType">
		/// A <see cref="System.Type"/>
		/// The returntype of the function you want to intect !ONLY TEMPORARY!
		/// </param>
		public AssemblyInjector ( string HostFile , string NewHostName, System.Type ReturnType)
		{
			//lets get the definitions out of our way.
			AssemblyDefinition asm      = AssemblyFactory.GetAssembly(HostFile); 
            TypeReference returntype    = asm.MainModule.Import(ReturnType); 
			
			//Field and which type:
			MethodDefinition testmethod = new MethodDefinition("Test", MethodAttributes.Private|MethodAttributes.Static, returntype);
            Instruction msg             = testmethod.Body.CilWorker.Create(OpCodes.Ldstr, "Hello from Test()");
            MethodReference writeline   = asm.MainModule.Import(typeof(Console).GetMethod("WriteLine",new Type[]{typeof(string)}));
        	
			
			//Test() // << testmethod
			//{
			//	string="Hello from Test()"; // << msg 
			//	Console.WriteLine(string); // << writeline
			//	return void;              
		    //}
			testmethod.Body.CilWorker.Append (msg);
            testmethod.Body.CilWorker.Append (testmethod.Body.CilWorker.Create (OpCodes.Call,writeline));
            testmethod.Body.CilWorker.Append (testmethod.Body.CilWorker.Create (OpCodes.Ret));
			Inject(testmethod,asm,GetTargetClass(asm));
		
		}
		
		public void BuildMethod()
		{
						
		}
		/// <summary>
		/// Execute injection
		/// </summary>
	    public void Inject(MethodDefinition testmethod ,AssemblyDefinition asm, int typearr )
		{
			MethodDefinition testmethod_def = asm.MainModule.Inject(testmethod, asm.MainModule.Types[typearr]);
			MethodReference  testmethod_ref = asm.MainModule.Import(testmethod_def);
            
            Instruction call_test = testmethod.Body.CilWorker.Create(OpCodes.Call, testmethod_ref);
            asm.EntryPoint.Body.CilWorker.InsertBefore (asm.EntryPoint.Body.Instructions[0],call_test);
            AssemblyFactory.SaveAssembly(asm, NewHostName);
            Console.WriteLine("Injection: Done. \n Patched executable {0} written.",NewHostName);				
		}
		
		/// <summary>
		/// Query the user for which target namespace and Class should be injected into.
		/// </summary>
		/// <param name="asm">
		/// A <see cref="AssemblyDefinition"/>
		/// </param>
		/// <returns>
		/// A <see cref="System.Int32"/>
		/// </returns>
		public int GetTargetClass(AssemblyDefinition asm)
		{
			Console.WriteLine("Into which Namespace shall be injected?");
			for(int i = 0; i < asm.MainModule.Types.Count;i++)
				Console.WriteLine("{0}. {1}",i,asm.MainModule.Types[i].FullName);
			Console.WriteLine("Please Type number of Type:");
			return Convert.ToInt32(Console.ReadLine());
		}
	}
}
