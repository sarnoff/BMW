attribute vec4 position;
attribute vec4 inputTextureCoordinate;

varying vec2 textureCoordinate;

void main()
{
	gl_Position = position;
	//gl_Position.y += sin(translate) / 3.0;
	textureCoordinate = inputTextureCoordinate.xy;
}