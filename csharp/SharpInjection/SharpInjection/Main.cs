//
//  Main.cs
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

namespace SharpInjection
{
	class MainClass
	{
		public static void Main (string[] args)
		{
			string file = "";
			string patched = "";

			foreach( string str in args)
			{
				if(str.Contains("--host="))
					file = str.Split('=')[1];
				if(str == "--help" || str == "-h" )
				{
					help();	
					return;
				}
				if(str.Contains("--patched="))
					patched = str.Split('=')[1];
			}
			System.IO.FileInfo fileInfo = new System.IO.FileInfo(file);
			if(!fileInfo.Exists)
			{	
				Console.WriteLine("File {0} not found",file);
				return;
			}
			if(patched == "")
			{
				patched = file;
				Console.WriteLine("Name of new Patched assembly file is not given. Will take host file name \"{0}\"",file);
			}
			AssemblyInjector injector = new AssemblyInjector(file,patched,typeof(void));
			
			return;			
		}
		
		/// <summary>
		/// Help Function for the console --help
		/// </summary>
		public static void help()
		{
			Console.WriteLine("SharpInjection - inject assemblies into .NET/Mono applications");			
			Console.WriteLine("--host=HOST\t host application assembly file we will inject");
			Console.WriteLine("--asm=ASSEMBLY\t assembly you want to inject (not yet implemented)");
			Console.WriteLine("--patched=PATCHED\t patched name at the end");
			Console.WriteLine("Have fun!");
		}
	}
}
