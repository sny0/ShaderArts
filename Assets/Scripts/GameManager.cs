using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    [SerializeField]
    private GameObject _quad;

    private MeshRenderer _meshRenderer = null;

    [SerializeField]
    private Material[] _materials;

    [SerializeField]
    private GameObject _images;

    [SerializeField]
    private Button _backToListButton;

    private int _selectedIndex = 0;

    private void Start()
    {
        _meshRenderer = _quad.GetComponent<MeshRenderer>();

        if(_meshRenderer == null)
        {
            Debug.Log("Mesh Renderer��������܂���ł����B");
        }

        _meshRenderer.material = _materials[_selectedIndex];
        _images.SetActive(true);
        _backToListButton.gameObject.SetActive(false);
    }


    public void OnImageClicked(int value)
    {
        Debug.Log("Clicked " + value + " !");

        _meshRenderer.material = _materials[value];
        _selectedIndex = value;

        _images.SetActive(false);
        _backToListButton.gameObject.SetActive(true);
    }

    public void OnBackToListButtonClicked()
    {
        _images.SetActive(true);
        _backToListButton.gameObject.SetActive(false);
    }
}