using Godot;
using System;
using System.IO.Compression;
public partial class unzipper : Node
{
	private string path;
	private string folderpath;
	
	//primarly, use this function before uncompress()
	public void load(string path)
	{
		this.path = path;
		var temp = path.Split('/');
		temp[temp.Length - 1] = "";
		folderpath = temp.Join("/");
	}
	
	//extracts .zip path
	public void extract()
	{
		if (this.path == null)
		{
			throw new Exception("Path didn't set. Did you use \"load()\" function?");
		}
		ZipFile.ExtractToDirectory(path, folderpath);
	}
}
