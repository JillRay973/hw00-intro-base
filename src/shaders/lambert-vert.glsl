#version 300 es

// #define DISPLACEMENT
float displacementScale = 0.4;

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

uniform vec4 u_Color;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

uniform float u_Time;

void main()
{
    fs_Col = u_Color;

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    vec4 displacedPos = modelposition;

#ifdef DISPLACEMENT
    displacedPos.y *= mix(0.1, 0.8, (cos(float(u_Time) / 500.0) + 1.0) / 2.0);
    displacedPos.x += sin(float(u_Time) / 250.0 + displacedPos.y);
    displacedPos.z += 2.0 * (sin(displacedPos.y) + cos(displacedPos.x));

    float uvScale = 10.0;
    float displacementNormal = sin(displacedPos.x * uvScale) + cos(displacedPos.y * uvScale) + sin(displacedPos.z * uvScale);
    displacedPos += displacementNormal * vs_Nor * 0.2;

    float displacementFactor = abs(fract(float(u_Time) / 7682.39) * 2.0 - 1.0);
    displacementFactor = smoothstep(0., 1., displacementFactor) * displacementScale;
    displacedPos = mix(modelposition, displacedPos, displacementFactor);
#endif

    fs_LightVec = lightPos - displacedPos;  // Compute the direction in which the light source lies

    fs_Pos = displacedPos;

    gl_Position = u_ViewProj * displacedPos; // gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}