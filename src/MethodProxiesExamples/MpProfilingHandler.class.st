"
I'm a more advanced proxy that propagates itself during execution.
When a proxy is executed, before letting the execution runs, it installs itself on all the implementators of the methods used in the method.

```
testCase := StringTest selector: #testAsCamelCase.
(MpMethodProxy onMethod: testCase testMethod handler: MpProfilingHandler) install.
testCase run.

proxies := MpMethodProxy allInstances.
proxies do: #uninstall.
```
"
Class {
	#name : #MpProfilingHandler,
	#superclass : #MpHandler,
	#instVars : [
		'count',
		'stacks'
	],
	#category : #MethodProxiesExamples
}

{ #category : #evaluating }
MpProfilingHandler >> beforeMethod [

	self count: self count + 1.
	
	"Only do instrumentation once"
	stacks add: thisContext stack copy.
	
	count > 1 ifTrue: [ ^ self ].
	proxy literalsEvenTheOnesInTheInnerBlocks
		select: [ :literal | literal isSymbol ]
		thenDo: [ :potentialSelector | self instrumentImplementorsOf: potentialSelector ]
]

{ #category : #accessing }
MpProfilingHandler >> count [

	^ count
]

{ #category : #accessing }
MpProfilingHandler >> count: anInteger [

	count := anInteger
]

{ #category : #initialization }
MpProfilingHandler >> initialize [

	super initialize.
	count := 0.
]

{ #category : #evaluating }
MpProfilingHandler >> instrumentImplementorsOf: potentialSelector [

	| proxy |
	potentialSelector implementors do: [ :method |
		proxy := MpMethodProxy onMethod: method handler: MpProfilingHandler new.
		proxy ifNotNil: [ proxy install ].
	]
]
